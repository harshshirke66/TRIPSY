import 'package:tripsy/core/models/profile_model.dart';

class Chat {
  final String id;
  final String? name;
  final bool isGroup;
  final String? coverImage;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final List<Profile> members;

  Chat({
    required this.id,
    this.name,
    this.isGroup = false,
    this.coverImage,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.members = const [],
  });

  factory Chat.fromJson(Map<String, dynamic> json, {List<Profile> members = const []}) {
    return Chat(
      id: json['id'] as String,
      name: json['name'] as String?,
      isGroup: json['is_group'] as bool? ?? false,
      coverImage: json['cover_image'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] != null 
          ? DateTime.parse(json['last_message_time']) 
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      members: members,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_group': isGroup,
      'cover_image': coverImage,
      'created_at': createdAt.toIso8601String(),
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'unread_count': unreadCount,
    };
  }

  Chat copyWith({
    String? id,
    String? name,
    bool? isGroup,
    String? coverImage,
    DateTime? createdAt,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    List<Profile>? members,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      isGroup: isGroup ?? this.isGroup,
      coverImage: coverImage ?? this.coverImage,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      members: members ?? this.members,
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String? content;
  final String? imageUrl;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    this.imageUrl,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
