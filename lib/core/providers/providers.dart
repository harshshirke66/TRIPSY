import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tripsy/core/models/profile_model.dart';
import 'package:tripsy/core/models/chat_model.dart';
import 'package:tripsy/core/models/trip_model.dart';
import 'package:tripsy/core/models/story_model.dart';
import 'package:tripsy/core/services/supabase_service.dart';

// --- AUTH / USER PROFILE PROVIDER ---
class CurrentUserNotifier extends StateNotifier<AsyncValue<Profile>> {
  CurrentUserNotifier() : super(const AsyncValue.loading()) {
    loadUser();
  }

  final _service = SupabaseService.instance;

  Future<void> loadUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _service.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(Profile updated) async {
    try {
      await _service.updateCurrentUserProfile(updated);
      state = AsyncValue.data(updated);
    } catch (e) {
      // Keep previous state but alert error
    }
  }
}

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<Profile>>((ref) {
  return CurrentUserNotifier();
});

// --- SWIPE DECK PROVIDER ---
class SwipeDeckState {
  final List<Profile> profiles;
  final bool isLoading;
  final String? matchedWithUserId; // Trigger popup if set

  SwipeDeckState({
    required this.profiles,
    this.isLoading = false,
    this.matchedWithUserId,
  });

  SwipeDeckState copyWith({
    List<Profile>? profiles,
    bool? isLoading,
    String? matchedWithUserId,
  }) {
    return SwipeDeckState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      matchedWithUserId: matchedWithUserId,
    );
  }
}

class SwipeDeckNotifier extends StateNotifier<SwipeDeckState> {
  SwipeDeckNotifier() : super(SwipeDeckState(profiles: [], isLoading: true)) {
    loadProfiles();
  }

  final _service = SupabaseService.instance;

  Future<void> loadProfiles() async {
    state = state.copyWith(isLoading: true);
    try {
      final profiles = await _service.getProfilesToSwipe();
      state = SwipeDeckState(profiles: profiles, isLoading: false);
    } catch (e) {
      state = SwipeDeckState(profiles: [], isLoading: false);
    }
  }

  Future<void> swipe(String swipedId, String direction) async {
    // Optimistic UI updates - remove the swiped card immediately
    final remaining = state.profiles.where((p) => p.id != swipedId).toList();
    
    // Call service to record swipe
    final isMatch = await _service.swipeUser(swipedId, direction);
    
    if (isMatch) {
      state = SwipeDeckState(
        profiles: remaining,
        isLoading: false,
        matchedWithUserId: swipedId,
      );
    } else {
      state = state.copyWith(profiles: remaining);
    }
  }

  void clearMatch() {
    state = state.copyWith(matchedWithUserId: null);
  }
}

final swipeDeckProvider = StateNotifierProvider<SwipeDeckNotifier, SwipeDeckState>((ref) {
  return SwipeDeckNotifier();
});

// --- CHAT LIST PROVIDER ---
class ChatListNotifier extends StateNotifier<AsyncValue<List<Chat>>> {
  ChatListNotifier() : super(const AsyncValue.loading()) {
    loadChats();
  }

  final _service = SupabaseService.instance;

  Future<void> loadChats() async {
    try {
      final list = await _service.getChats();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addMockChat(Chat newChat) {
    if (state.hasValue) {
      final current = state.value!;
      if (!current.any((c) => c.id == newChat.id)) {
        state = AsyncValue.data([newChat, ...current]);
      }
    }
  }
}

final chatListProvider = StateNotifierProvider<ChatListNotifier, AsyncValue<List<Chat>>>((ref) {
  return ChatListNotifier();
});

// --- CHAT MESSAGES PROVIDER ---
class MessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final String chatId;
  MessagesNotifier(this.chatId) : super(const AsyncValue.loading()) {
    loadMessages();
  }

  final _service = SupabaseService.instance;

  Future<void> loadMessages() async {
    try {
      final list = await _service.getMessages(chatId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> send(String? content, {String? imageUrl, required WidgetRef ref}) async {
    try {
      final msg = await _service.sendMessage(chatId, content, imageUrl: imageUrl);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, msg]);
      }
      
      // Refresh chat list to update last message
      ref.read(chatListProvider.notifier).loadChats();
      
      // Simulate receipt feedback update for mock messages
      if (!_service.isLiveMode) {
        Future.delayed(const Duration(seconds: 2), () {
          loadMessages();
          ref.read(chatListProvider.notifier).loadChats();
        });
      }
    } catch (e) {
      // Handle send error
    }
  }
}

final messagesProvider = StateNotifierProvider.family<MessagesNotifier, AsyncValue<List<Message>>, String>((ref, chatId) {
  return MessagesNotifier(chatId);
});

// --- TRIP ROOMS PROVIDER ---
class TripRoomsNotifier extends StateNotifier<AsyncValue<List<TripRoom>>> {
  TripRoomsNotifier() : super(const AsyncValue.loading()) {
    loadTrips();
  }

  final _service = SupabaseService.instance;

  Future<void> loadTrips() async {
    try {
      final list = await _service.getTripRooms();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createTrip(String title, String description, String destination, double budget, DateTime start, DateTime end, String coverImage) async {
    try {
      final myProfileRes = await _service.getCurrentUser();
      final newRoom = TripRoom(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        creatorId: myProfileRes.id,
        title: title,
        description: description,
        destination: destination,
        startDate: start,
        endDate: end,
        budget: budget,
        coverImage: coverImage,
        createdAt: DateTime.now(),
        members: [myProfileRes],
      );

      final created = await _service.createTripRoom(newRoom);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, created]);
      }
    } catch (e) {
      // Handle create trip error
    }
  }

  Future<void> addExpenseItem(String tripId, String desc, double amount) async {
    try {
      await _service.addExpense(tripId, desc, amount);
      loadTrips(); // Refresh detail weights
    } catch (e) {
      // handle error
    }
  }

  Future<void> addItineraryItem(String tripId, int day, String time, String title, String desc, String location) async {
    try {
      await _service.addItineraryItem(tripId, day, time, title, desc, location);
      loadTrips(); // Refresh itinerary points
    } catch (e) {
      // handle error
    }
  }
}

final tripRoomsProvider = StateNotifierProvider<TripRoomsNotifier, AsyncValue<List<TripRoom>>>((ref) {
  return TripRoomsNotifier();
});

// --- STORY FEEDS PROVIDER ---
class StoryListNotifier extends StateNotifier<AsyncValue<List<Story>>> {
  StoryListNotifier() : super(const AsyncValue.loading()) {
    loadStories();
  }

  final _service = SupabaseService.instance;

  Future<void> loadStories() async {
    try {
      final list = await _service.getStories();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final storyListProvider = StateNotifierProvider<StoryListNotifier, AsyncValue<List<Story>>>((ref) {
  return StoryListNotifier();
});
