import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants.dart';
import 'emergency_service.dart';

/// Drives on-device evidence capture during an active SOS: periodic photos
/// (front + back), continuous chunked back-camera video, and continuous
/// chunked audio — each chunk is uploaded to the backend as a real file via
/// multipart/form-data the moment it's finished recording. No Base64 at any
/// point; bytes go straight from the camera/mic to disk to the network.
///
/// Note: most phones cannot stream the front and back camera at the same
/// time, so this captures continuous video on the back camera and briefly
/// switches to the front camera every [evidencePhotoIntervalSeconds] to grab
/// one selfie frame before switching back — matching the "front + back
/// photos, continuous back-camera video" spec without requiring hardware
/// dual-camera support.
class EvidenceCaptureService {
  EvidenceCaptureService(this.emergencyId, this.emergencyService, {this.onLog});

  final String emergencyId;
  final EmergencyService emergencyService;
  final void Function(String message)? onLog;

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  final _recorder = AudioRecorder();

  Timer? _photoTimer;
  Timer? _videoChunkTimer;
  Timer? _audioChunkTimer;
  bool _busySwitchingCamera = false;
  bool _disposed = false;

  Future<void> start() async {
    try {
      _cameras = await availableCameras();
    } catch (_) {
      _cameras = [];
    }

    await _startBackCameraAndVideo();
    _photoTimer = Timer.periodic(
      const Duration(seconds: AppConstants.evidencePhotoIntervalSeconds),
      (_) => _captureFrontSelfieThenResumeVideo(),
    );

    await _startAudioChunk();
    _audioChunkTimer = Timer.periodic(
      const Duration(seconds: AppConstants.evidenceAudioChunkSeconds),
      (_) => _rotateAudioChunk(),
    );
  }

  CameraDescription? _findCamera(CameraLensDirection direction) {
    for (final c in _cameras) {
      if (c.lensDirection == direction) return c;
    }
    return _cameras.isNotEmpty ? _cameras.first : null;
  }

  Future<void> _startBackCameraAndVideo() async {
    final back = _findCamera(CameraLensDirection.back);
    if (back == null) return;
    _controller = CameraController(back, ResolutionPreset.medium, enableAudio: false);
    try {
      await _controller!.initialize();
      await _controller!.startVideoRecording();
      _videoChunkTimer = Timer.periodic(
        const Duration(seconds: AppConstants.evidenceVideoChunkSeconds),
        (_) => _rotateVideoChunk(),
      );
    } catch (e) {
      onLog?.call('Video capture unavailable: $e');
    }
  }

  Future<void> _rotateVideoChunk() async {
    if (_disposed || _controller == null || !_controller!.value.isRecordingVideo) return;
    try {
      final file = await _controller!.stopVideoRecording();
      unawaited(_uploadFile('video', File(file.path)));
      if (!_disposed) await _controller!.startVideoRecording();
    } catch (e) {
      onLog?.call('Video chunk error: $e');
    }
  }

  Future<void> _captureFrontSelfieThenResumeVideo() async {
    if (_disposed || _busySwitchingCamera) return;
    final front = _findCamera(CameraLensDirection.front);
    if (front == null || _controller == null) return;
    _busySwitchingCamera = true;
    try {
      final wasRecording = _controller!.value.isRecordingVideo;
      if (wasRecording) {
        final file = await _controller!.stopVideoRecording();
        unawaited(_uploadFile('video', File(file.path)));
      }
      await _controller!.dispose();

      final frontController = CameraController(front, ResolutionPreset.medium, enableAudio: false);
      await frontController.initialize();
      final selfie = await frontController.takePicture();
      unawaited(_uploadFile('photo', File(selfie.path)));
      await frontController.dispose();

      await _startBackCameraAndVideo();
      // A quick back-camera still, taken just after the selfie. Not all devices support
      // capturing a still while a video recording is already in progress, so this is
      // best-effort and failures are swallowed rather than interrupting the SOS flow.
      if (_controller != null) {
        try {
          final backShot = await _controller!.takePicture();
          unawaited(_uploadFile('photo', File(backShot.path)));
        } catch (_) {
          // ignored — video recording already covers the back camera.
        }
      }
    } catch (e) {
      onLog?.call('Photo capture error: $e');
    } finally {
      _busySwitchingCamera = false;
    }
  }

  Future<void> _startAudioChunk() async {
    if (!await _recorder.hasPermission()) return;
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
  }

  Future<void> _rotateAudioChunk() async {
    if (_disposed) return;
    try {
      final path = await _recorder.stop();
      if (path != null) unawaited(_uploadFile('audio', File(path)));
      if (!_disposed) await _startAudioChunk();
    } catch (e) {
      onLog?.call('Audio chunk error: $e');
    }
  }

  Future<void> _uploadFile(String kind, File file) async {
    try {
      await emergencyService.uploadEvidence(emergencyId, kind, file);
    } catch (e) {
      onLog?.call('Upload failed ($kind): $e');
    }
  }

  Future<void> stop() async {
    _disposed = true;
    _photoTimer?.cancel();
    _videoChunkTimer?.cancel();
    _audioChunkTimer?.cancel();

    try {
      if (_controller != null && _controller!.value.isRecordingVideo) {
        final file = await _controller!.stopVideoRecording();
        unawaited(_uploadFile('video', File(file.path)));
      }
      await _controller?.dispose();
    } catch (_) {}

    try {
      final path = await _recorder.stop();
      if (path != null) unawaited(_uploadFile('audio', File(path)));
      await _recorder.dispose();
    } catch (_) {}
  }
}
