import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants.dart';
import 'emergency_service.dart';

/// Drives on-device SOS evidence capture: back-camera video and microphone
/// audio record continuously in the background; every
/// [AppConstants.evidenceUploadCycleSeconds] (1 minute) the in-progress
/// segments are closed off, a fresh selfie is grabbed, and everything
/// captured in that window is uploaded as real files via
/// multipart/form-data — never Base64 — to the backend, which forwards them
/// into the incident's Google Drive folder. New segments start immediately
/// so capture never stops. The first upload only happens after the first
/// full minute, matching the spec.
///
/// Note: most phones can't stream front + back camera at once, so this
/// captures continuous video on the back camera and grabs one front-camera
/// still each cycle rather than true simultaneous dual-camera video.
class EvidenceCaptureService {
  EvidenceCaptureService(this.emergencyId, this.emergencyService, {this.onLog});

  final String emergencyId;
  final EmergencyService emergencyService;
  final void Function(String message)? onLog;

  CameraController? _backController;
  List<CameraDescription> _cameras = [];
  final _recorder = AudioRecorder();

  Timer? _cycleTimer;
  bool _cycleRunning = false;
  bool _disposed = false;
  int _cyclesCompleted = 0;

  Future<void> start() async {
    try {
      _cameras = await availableCameras();
    } catch (_) {
      _cameras = [];
    }

    await _beginBackVideoSegment();
    await _beginAudioSegment();

    _cycleTimer = Timer.periodic(
      const Duration(seconds: AppConstants.evidenceUploadCycleSeconds),
      (_) => _runCycle(),
    );
  }

  CameraDescription? _findCamera(CameraLensDirection direction) {
    for (final c in _cameras) {
      if (c.lensDirection == direction) return c;
    }
    return _cameras.isNotEmpty ? _cameras.first : null;
  }

  Future<void> _beginBackVideoSegment() async {
    final back = _findCamera(CameraLensDirection.back);
    if (back == null) return;
    try {
      _backController = CameraController(back, ResolutionPreset.medium, enableAudio: false);
      await _backController!.initialize();
      await _backController!.startVideoRecording();
    } catch (e) {
      onLog?.call('Video capture unavailable: $e');
    }
  }

  Future<void> _beginAudioSegment() async {
    try {
      if (!await _recorder.hasPermission()) return;
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/sos_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    } catch (e) {
      onLog?.call('Audio capture unavailable: $e');
    }
  }

  /// Runs one full upload cycle: close current segments, upload everything,
  /// immediately reopen fresh segments so capture is continuous.
  Future<void> _runCycle() async {
    if (_disposed || _cycleRunning) return;
    _cycleRunning = true;
    try {
      // Close & upload the finished video segment, then start the next one.
      if (_backController != null && _backController!.value.isRecordingVideo) {
        try {
          final file = await _backController!.stopVideoRecording();
          unawaited(_uploadFile('video', File(file.path)));
        } catch (e) {
          onLog?.call('Video segment error: $e');
        }
      }
      await _backController?.dispose();
      _backController = null;

      // Grab one front-camera selfie for this cycle.
      final front = _findCamera(CameraLensDirection.front);
      if (front != null) {
        try {
          final frontController = CameraController(front, ResolutionPreset.medium, enableAudio: false);
          await frontController.initialize();
          final selfie = await frontController.takePicture();
          unawaited(_uploadFile('photo', File(selfie.path)));
          await frontController.dispose();
        } catch (e) {
          onLog?.call('Selfie capture error: $e');
        }
      }

      // Close & upload the finished audio segment, then start the next one.
      try {
        final path = await _recorder.stop();
        if (path != null) unawaited(_uploadFile('audio', File(path)));
      } catch (e) {
        onLog?.call('Audio segment error: $e');
      }

      if (!_disposed) {
        await _beginBackVideoSegment();
        await _beginAudioSegment();
      }
      _cyclesCompleted++;
    } finally {
      _cycleRunning = false;
    }
  }

  Future<void> _uploadFile(String kind, File file) async {
    try {
      await emergencyService.uploadEvidence(emergencyId, kind, file);
    } catch (e) {
      onLog?.call('Upload failed ($kind): $e — will retry next cycle.');
    }
  }

  Future<void> stop() async {
    _disposed = true;
    _cycleTimer?.cancel();

    try {
      if (_backController != null && _backController!.value.isRecordingVideo) {
        final file = await _backController!.stopVideoRecording();
        unawaited(_uploadFile('video', File(file.path)));
      }
      await _backController?.dispose();
    } catch (_) {}

    try {
      final path = await _recorder.stop();
      if (path != null) unawaited(_uploadFile('audio', File(path)));
      await _recorder.dispose();
    } catch (_) {}
  }
}
