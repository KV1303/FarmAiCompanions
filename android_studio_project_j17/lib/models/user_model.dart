class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final bool isSubscribed;
  final String? subscriptionEndDate;
  final String? location;
  final String? preferredLanguage;
  final String? profileImageUrl;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.isSubscribed = false,
    this.subscriptionEndDate,
    this.location,
    this.preferredLanguage = 'hi', // Default to Hindi
    this.profileImageUrl,
    this.preferences,
  });

  // Create from Firebase auth + firestore data
  factory UserModel.fromFirebase(Map<String, dynamic> data, String uid) {
    return UserModel(
      id: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      isSubscribed: data['isSubscribed'] ?? false,
      subscriptionEndDate: data['subscriptionEndDate'],
      location: data['location'],
      preferredLanguage: data['preferredLanguage'] ?? 'hi',
      profileImageUrl: data['profileImageUrl'],
      preferences: data['preferences'],
    );
  }

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'isSubscribed': isSubscribed,
      'subscriptionEndDate': subscriptionEndDate,
      'location': location,
      'preferredLanguage': preferredLanguage,
      'profileImageUrl': profileImageUrl,
      'preferences': preferences,
    };
  }

  // Create a copy of this user with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    bool? isSubscribed,
    String? subscriptionEndDate,
    String? location,
    String? preferredLanguage,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      location: location ?? this.location,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
    );
  }
}