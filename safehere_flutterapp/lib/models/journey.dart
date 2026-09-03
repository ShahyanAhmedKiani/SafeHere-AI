class Journey {
  final String id;
  final String fromLabel;
  final String toLabel;
  final double? fromLat;
  final double? fromLng;
  final double? toLat;
  final double? toLng;
  final String status; // planned | active | completed | deviated
  final String? trustedContactId;
  final String? trustedContactName;
  final bool notifyOnDeviation;
  final double? currentLat;
  final double? currentLng;
  final int routeSafetyPercent;
  final int? etaMinutes;
  final double offRouteDistanceM;

  Journey({
    required this.id,
    required this.fromLabel,
    required this.toLabel,
    this.fromLat,
    this.fromLng,
    this.toLat,
    this.toLng,
    required this.status,
    this.trustedContactId,
    this.trustedContactName,
    required this.notifyOnDeviation,
    this.currentLat,
    this.currentLng,
    required this.routeSafetyPercent,
    this.etaMinutes,
    required this.offRouteDistanceM,
  });

  bool get isDeviated => status == 'deviated';
  bool get isActive => status == 'active' || status == 'deviated';

  factory Journey.fromJson(Map<String, dynamic> json) => Journey(
        id: json['id'],
        fromLabel: json['from_label'],
        toLabel: json['to_label'],
        fromLat: (json['from_lat'] as num?)?.toDouble(),
        fromLng: (json['from_lng'] as num?)?.toDouble(),
        toLat: (json['to_lat'] as num?)?.toDouble(),
        toLng: (json['to_lng'] as num?)?.toDouble(),
        status: json['status'],
        trustedContactId: json['trusted_contact_id'],
        trustedContactName: json['trusted_contact_name'],
        notifyOnDeviation: json['notify_on_deviation'] ?? true,
        currentLat: (json['current_lat'] as num?)?.toDouble(),
        currentLng: (json['current_lng'] as num?)?.toDouble(),
        routeSafetyPercent: json['route_safety_percent'] ?? 100,
        etaMinutes: json['eta_minutes'],
        offRouteDistanceM: (json['off_route_distance_m'] as num?)?.toDouble() ?? 0.0,
      );
}
