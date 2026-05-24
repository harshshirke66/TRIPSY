import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tripsy/core/models/chat_model.dart';
import 'package:tripsy/core/models/profile_model.dart';
import 'package:tripsy/core/theme/colors.dart';
import 'package:tripsy/core/widgets/glass_container.dart';
import 'package:tripsy/core/widgets/aurora_background.dart';
import 'package:tripsy/core/providers/providers.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatsState = ref.watch(chatListProvider);
    final deckState = ref.watch(swipeDeckProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              _buildSearchBar(),
              
              // Matches section
              _buildMatchesSection(deckState),
              const SizedBox(height: 16),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Conversations List
              Expanded(
                child: chatsState.when(
                  data: (chats) => _buildChatsList(chats),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: TripsyColors.sunsetOrange),
                  ),
                  error: (err, _) => Center(
                    child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 80), // bottom nav space
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inbox',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Connect and plan with your matches',
            style: TextStyle(
              fontSize: 14,
              color: TripsyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search chats or trips...',
          hintStyle: const TextStyle(color: TripsyColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, color: TripsyColors.textMuted, size: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: TripsyColors.skyBlue, width: 1.5),
          ),
          fillColor: Colors.white.withValues(alpha: 0.03),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildMatchesSection(SwipeDeckState deckState) {
    if (deckState.profiles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'New Matches',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: TripsyColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 84,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: deckState.profiles.length,
            itemBuilder: (context, index) {
              final user = deckState.profiles[index];
              return GestureDetector(
                onTap: () {
                  // Direct message match
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        chatId: 'chat_${user.id}',
                        title: user.fullName,
                        avatarUrl: user.avatarUrl,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: TripsyColors.sunsetGradient,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: TripsyColors.deepSpace,
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(user.avatarUrl),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatsList(List<Chat> chats) {
    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: TripsyColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'No messages yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Match with explorers to start chatting!',
              style: TextStyle(fontSize: 13, color: TripsyColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        final otherUser = chat.members.firstWhere(
          (m) => m.id != 'current_user_id',
          orElse: () => chat.members.first,
        );

        final title = chat.isGroup ? (chat.name ?? 'Trip Group') : otherUser.fullName;
        final avatar = chat.isGroup ? (chat.coverImage ?? '') : otherUser.avatarUrl;
        final formattedTime = chat.lastMessageTime != null
            ? DateFormat.jm().format(chat.lastMessageTime!)
            : '';

        final hasUnread = chat.unreadCount > 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  chatId: chat.id,
                  title: title,
                  avatarUrl: avatar,
                  isGroup: chat.isGroup,
                  members: chat.members,
                ),
              ),
            );
          },
          child: GlassContainer(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            borderRadius: 20,
            opacity: hasUnread ? 0.07 : 0.03,
            borderSide: BorderSide(
              color: hasUnread
                  ? TripsyColors.skyBlue.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
              width: hasUnread ? 1.2 : 1.0,
            ),
            shadows: hasUnread
                ? [
                    BoxShadow(
                      color: TripsyColors.skyBlue.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
            child: Row(
              children: [
                if (chat.isGroup)
                  _buildGroupAvatar(avatar, chat.members)
                else
                  Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasUnread ? TripsyColors.skyBlue : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(avatar),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: hasUnread ? Colors.white : Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 11,
                              color: TripsyColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        chat.lastMessage ?? 'No messages yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: hasUnread
                              ? Colors.white
                              : TripsyColors.textSecondary,
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: TripsyColors.sunsetGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: TripsyColors.sunsetOrange.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupAvatar(String coverUrl, List<Profile> members) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black38, blurRadius: 4),
                ],
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  members.length > 1 ? members[1].avatarUrl : 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: TripsyColors.deepSpace, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 4),
                ],
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  members.isNotEmpty ? members[0].avatarUrl : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String title;
  final String avatarUrl;
  final bool isGroup;
  final List<Profile> members;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.title,
    required this.avatarUrl,
    this.isGroup = false,
    this.members = const [],
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider(widget.chatId));

    ref.listen(messagesProvider(widget.chatId), (prev, next) {
      if (next.hasValue) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.black.withValues(alpha: 0.15),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            if (widget.isGroup)
              _buildGroupAvatarMini(widget.members)
            else
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.avatarUrl),
              ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: TripsyColors.activeGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isGroup ? '${widget.members.length} members' : 'Online',
                      style: const TextStyle(fontSize: 11, color: TripsyColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AuroraBackground(
        child: Column(
          children: [
            Expanded(
              child: messagesState.when(
                data: (messages) {
                  _scrollToBottom();
                  return _buildMessagesList(messages);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: TripsyColors.sunsetOrange),
                ),
                error: (err, _) => Center(
                  child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
            _buildInputBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupAvatarMini(List<Profile> members) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: CircleAvatar(
              radius: 11,
              backgroundImage: NetworkImage(
                members.length > 1 ? members[1].avatarUrl : 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 11,
                backgroundImage: NetworkImage(
                  members.isNotEmpty ? members[0].avatarUrl : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<Message> messages) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 36, color: TripsyColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'Say hello!',
              style: TextStyle(fontSize: 14, color: TripsyColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
        bottom: 20,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == 'current_user_id';
        
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? const LinearGradient(
                          colors: [TripsyColors.skyBlue, TripsyColors.sunsetOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isMe ? null : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                    bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                  ),
                  border: isMe 
                      ? null 
                      : Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  boxShadow: isMe
                      ? [
                          BoxShadow(
                            color: TripsyColors.sunsetOrange.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(message.imageUrl!, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (message.content != null)
                      Text(
                        message.content!,
                        style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.45),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat.jm().format(message.createdAt),
                      style: const TextStyle(fontSize: 10, color: TripsyColors.textMuted),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all_rounded, size: 14, color: TripsyColors.oceanTeal),
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputBox() {
    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          opacity: 0.05,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt_rounded, color: TripsyColors.textSecondary),
                onPressed: () {
                  ref.read(messagesProvider(widget.chatId).notifier).send(
                    null,
                    imageUrl: 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=600&auto=format&fit=crop',
                    ref: ref,
                  );
                },
              ),
              Expanded(
                child: TextField(
                  controller: _msgController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: TripsyColors.textMuted, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              GestureDetector(
                onTap: _handleSend,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: TripsyColors.sunsetGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: TripsyColors.sunsetOrange,
                        blurRadius: 10,
                        spreadRadius: -2,
                      )
                    ],
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSend() {
    if (_msgController.text.trim().isEmpty) return;
    ref.read(messagesProvider(widget.chatId).notifier).send(
          _msgController.text.trim(),
          ref: ref,
        );
    _msgController.clear();
    _scrollToBottom();
  }
}

