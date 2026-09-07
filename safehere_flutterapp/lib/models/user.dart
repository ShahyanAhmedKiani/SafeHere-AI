class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final String avatarColor;
  final bool isVerified;
  final bool onboardingComplete;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    required this.avatarColor,
    required this.isVerified,
    required this.onboardingComplete,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        fullName: json['full_name'],
        email: json['email'],
        phone: json['phone'],
        role: json['role'] ?? 'user',
        avatarColor: json['avatar_color'] ?? '#D96C8A',
        isVerified: json['is_verified'] ?? false,
        onboardingComplete: json['onboarding_complete'] ?? false,
      );
}
