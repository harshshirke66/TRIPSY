class Profile {
  final String id;
  final String username;
  final String fullName;
  final String avatarUrl;
  final List<String> images;
  final String bio;
  final String gender;
  final List<String> travelInterests;
  final List<String> destinationPreferences;
  final String budgetStyle; // backpacker, budget, moderate, luxury
  final List<String> languages;
  final List<String> personalityTags;
  final bool isVerified;
  final double latitude;
  final double longitude;
  final Map<String, String> socialLinks;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    required this.images,
    required this.bio,
    required this.gender,
    required this.travelInterests,
    required this.destinationPreferences,
    required this.budgetStyle,
    required this.languages,
    required this.personalityTags,
    required this.isVerified,
    required this.latitude,
    required this.longitude,
    required this.socialLinks,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      images: List<String>.from(json['images'] ?? []),
      bio: json['bio'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      travelInterests: List<String>.from(json['travel_interests'] ?? []),
      destinationPreferences: List<String>.from(json['destination_preferences'] ?? []),
      budgetStyle: json['budget_style'] as String? ?? 'moderate',
      languages: List<String>.from(json['languages'] ?? []),
      personalityTags: List<String>.from(json['personality_tags'] ?? []),
      isVerified: json['is_verified'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      socialLinks: Map<String, String>.from(json['social_links'] ?? {}),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'images': images,
      'bio': bio,
      'gender': gender,
      'travel_interests': travelInterests,
      'destination_preferences': destinationPreferences,
      'budget_style': budgetStyle,
      'languages': languages,
      'personality_tags': personalityTags,
      'is_verified': isVerified,
      'latitude': latitude,
      'longitude': longitude,
      'social_links': socialLinks,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? username,
    String? fullName,
    String? avatarUrl,
    List<String>? images,
    String? bio,
    String? gender,
    List<String>? travelInterests,
    List<String>? destinationPreferences,
    String? budgetStyle,
    List<String>? languages,
    List<String>? personalityTags,
    bool? isVerified,
    double? latitude,
    double? longitude,
    Map<String, String>? socialLinks,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      images: images ?? this.images,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      travelInterests: travelInterests ?? this.travelInterests,
      destinationPreferences: destinationPreferences ?? this.destinationPreferences,
      budgetStyle: budgetStyle ?? this.budgetStyle,
      languages: languages ?? this.languages,
      personalityTags: personalityTags ?? this.personalityTags,
      isVerified: isVerified ?? this.isVerified,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      socialLinks: socialLinks ?? this.socialLinks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
