class Incident {
  final String id;
  final double latitude;
  final double longitude;
  final String type;
  final String severity; // low | medium | high
  final String? description;
  final String reportedAt;

  Incident({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.severity,
    this.description,
    required this.reportedAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) => Incident(
        id: json['id'],
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        type: json['type'],
        severity: json['severity'],
        description: json['description'],
        reportedAt: json['reported_at'],
      );
}

class SafetyStatus {
  final String status; // safe | caution | high_risk
  final int score;
  final String reason;
  final int incidentCount;
  final List<Incident> incidents;

  SafetyStatus({
    required this.status,
    required this.score,
    required this.reason,
    required this.incidentCount,
    required this.incidents,
  });

  factory SafetyStatus.fromJson(Map<String, dynamic> json) => SafetyStatus(
        status: json['status'],
        score: json['score'],
        reason: json['reason'],
        incidentCount: json['incident_count'] ?? 0,
        incidents: (json['incidents'] as List? ?? []).map((e) => Incident.fromJson(e)).toList(),
      );
}
