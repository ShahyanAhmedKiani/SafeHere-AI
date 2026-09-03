class TrustedContact {
  final String id;
  final String name;
  final String relationship;
  final String? phone;
  final String? email;
  final String avatarColor;
  final String status; // pending | verified | active
  final bool online;
  final bool locationSharing;
  final bool isEmergencyContact;

  TrustedContact({
    required this.id,
    required this.name,
    required this.relationship,
    this.phone,
    this.email,
    required this.avatarColor,
    required this.status,
    required this.online,
    required this.locationSharing,
    required this.isEmergencyContact,
  });

  factory TrustedContact.fromJson(Map<String, dynamic> json) => TrustedContact(
        id: json['id'],
        name: json['name'],
        relationship: json['relationship'] ?? '',
        phone: json['phone'],
        email: json['email'],
        avatarColor: json['avatar_color'] ?? '#9B8AFB',
        status: json['status'] ?? 'pending',
        online: json['online'] ?? false,
        locationSharing: json['location_sharing'] ?? false,
        isEmergencyContact: json['is_emergency_contact'] ?? true,
      );
}
