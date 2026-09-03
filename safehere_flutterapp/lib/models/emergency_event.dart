class LocationPoint {
  final double latitude;
  final double longitude;
  final String timestamp;

  LocationPoint({required this.latitude, required this.longitude, required this.timestamp});

  factory LocationPoint.fromJson(Map<String, dynamic> json) => LocationPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timestamp: json['timestamp'] ?? '',
      );
}

class EmergencyEvent {
  final String id;
  final String ownerId;
  final String type;
  final String status; // active | resolved | cancelled | false_alarm
  final double? latitude;
  final double? longitude;
  final List<LocationPoint> locationHistory;
  final int? batteryLevel;
  final String startedAt;
  final String? resolvedAt;
  final int contactsNotified;
  final bool evidenceRecording;
  final int evidenceUploadProgress;
  final List<String> evidencePhotos;
  final List<String> evidenceVideos;
  final List<String> evidenceClips;

  EmergencyEvent({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.status,
    this.latitude,
    this.longitude,
    required this.locationHistory,
    this.batteryLevel,
    required this.startedAt,
    this.resolvedAt,
    required this.contactsNotified,
    required this.evidenceRecording,
    required this.evidenceUploadProgress,
    required this.evidencePhotos,
    required this.evidenceVideos,
    required this.evidenceClips,
  });

  bool get isActive => status == 'active';

  factory EmergencyEvent.fromJson(Map<String, dynamic> json) => EmergencyEvent(
        id: json['id'],
        ownerId: json['owner_id'],
        type: json['type'],
        status: json['status'],
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        locationHistory: (json['location_history'] as List? ?? [])
            .map((e) => LocationPoint.fromJson(e))
            .toList(),
        batteryLevel: json['battery_level'],
        startedAt: json['started_at'],
        resolvedAt: json['resolved_at'],
        contactsNotified: json['contacts_notified'] ?? 0,
        evidenceRecording: json['evidence_recording'] ?? false,
        evidenceUploadProgress: json['evidence_upload_progress'] ?? 0,
        evidencePhotos: List<String>.from(json['evidence_photos'] ?? []),
        evidenceVideos: List<String>.from(json['evidence_videos'] ?? []),
        evidenceClips: List<String>.from(json['evidence_clips'] ?? []),
      );
}
