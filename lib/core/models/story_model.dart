import 'package:tripsy/core/models/profile_model.dart';

class Story {
  final String id;
  final String profileId;
  final String mediaUrl;
  final String? caption;
  final String? locationName;
  final int likesCount;
  final DateTime createdAt;
  final Profile? profile;

  Story({
    required this.id,
    required this.profileId,
    required this.mediaUrl,
    this.caption,
    this.locationName,
    this.likesCount = 0,
    required this.createdAt,
    this.profile,
  });

  factory Story.fromJson(Map<String, dynamic> json, {Profile? profile}) {
    return Story(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      mediaUrl: json['media_url'] as String,
      caption: json['caption'] as String?,
      locationName: json['location_name'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      profile: profile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'media_url': mediaUrl,
      'caption': caption,
      'location_name': locationName,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Story copyWith({
    String? id,
    String? profileId,
    String? mediaUrl,
    String? caption,
    String? locationName,
    int? likesCount,
    DateTime? createdAt,
    Profile? profile,
  }) {
    return Story(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      locationName: locationName ?? this.locationName,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
      profile: profile ?? this.profile,
    );
  }
}
