class User {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? phone;
  final DateTime createdAt;
  final bool isActive;
  final String? profileImage;
  
  // Subscription related fields
  final bool hasActiveSubscription;
  final DateTime? subscriptionEndDate;
  final int? trialDaysRemaining;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.phone,
    required this.createdAt,
    required this.isActive,
    this.profileImage,
    this.hasActiveSubscription = false,
    this.subscriptionEndDate,
    this.trialDaysRemaining,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isActive: json['is_active'] ?? true,
      profileImage: json['profile_image'],
      hasActiveSubscription: json['has_active_subscription'] ?? false,
      subscriptionEndDate: json['subscription_end_date'] != null 
          ? DateTime.parse(json['subscription_end_date']) 
          : null,
      trialDaysRemaining: json['trial_days_remaining'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'profile_image': profileImage,
      'has_active_subscription': hasActiveSubscription,
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
      'trial_days_remaining': trialDaysRemaining,
    };
  }
}