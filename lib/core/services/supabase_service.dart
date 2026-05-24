import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tripsy/core/models/profile_model.dart';
import 'package:tripsy/core/models/chat_model.dart';
import 'package:tripsy/core/models/trip_model.dart';
import 'package:tripsy/core/models/story_model.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseService._internal();

  String? _supabaseUrl;
  String? _supabaseAnonKey;
  bool _isSupabaseInitialized = false;

  void initializeSupabase({required String url, required String anonKey}) {
    _supabaseUrl = url;
    _supabaseAnonKey = anonKey;
    _isSupabaseInitialized = true;
  }

  bool get isLiveMode => _isSupabaseInitialized && _supabaseUrl != null && _supabaseAnonKey != null;

  SupabaseClient get client {
    if (!isLiveMode) {
      throw Exception("Supabase is not initialized. Please configure your .env file at the project root.");
    }
    return Supabase.instance.client;
  }

  // --- AUTH SERVICES ---

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
    String? username,
    String? gender,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'username': username,
        'gender': gender,
      }..removeWhere((_, value) => value == null),
    );
    final user = response.user;
    if (user != null) {
      final finalUsername = username ?? '${email.split('@')[0]}_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      final finalFullName = fullName ?? email.split('@')[0];
      final finalGender = gender ?? 'Not specified';

      final defaultProfile = Profile(
        id: user.id,
        username: finalUsername,
        fullName: finalFullName,
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        images: [],
        bio: 'Hello! I am new to Tripsy.',
        gender: finalGender,
        travelInterests: [],
        destinationPreferences: [],
        budgetStyle: 'moderate',
        languages: ['English'],
        personalityTags: [],
        isVerified: false,
        latitude: 0.0,
        longitude: 0.0,
        socialLinks: {},
        createdAt: DateTime.now(),
      );
      await client.from('profiles').upsert(defaultProfile.toJson());
    }
    return response;
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> completeProfileSetup({required String bio, required String avatarUrl}) async {
    final user = client.auth.currentUser;
    if (user != null) {
      await client.from('profiles').update({
        'bio': bio,
        'avatar_url': avatarUrl,
      }).eq('id', user.id);
    }
  }

  // --- DATABASE SERVICES ---

  Future<Profile> getCurrentUser() async {
    final user = client.auth.currentUser;
    if (user != null) {
      final res = await client.from('profiles').select().eq('id', user.id).single();
      return Profile.fromJson(res);
    }
    throw Exception("No authenticated user found.");
  }

  Future<void> updateCurrentUserProfile(Profile profile) async {
    await client.from('profiles').upsert(profile.toJson());
  }

  Future<List<Profile>> getProfilesToSwipe() async {
    final user = client.auth.currentUser;
    if (user != null) {
      final swipedRes = await client.from('swipes').select('swiped_id').eq('swiper_id', user.id);
      final swipedIds = (swipedRes as List).map((s) => s['swiped_id'] as String).toList();
      
      final query = client.from('profiles').select().neq('id', user.id);
      if (swipedIds.isNotEmpty) {
        query.not('id', 'in', swipedIds);
      }
      final res = await query;
      return (res as List).map((p) => Profile.fromJson(p)).toList();
    }
    return [];
  }

  Future<bool> swipeUser(String swipedId, String direction) async {
    final user = client.auth.currentUser;
    if (user != null) {
      await client.from('swipes').insert({
        'swiper_id': user.id,
        'swiped_id': swipedId,
        'direction': direction,
      });

      if (direction == 'like' || direction == 'super') {
        // Check if match
        final matchRes = await client
            .from('swipes')
            .select()
            .eq('swiper_id', swipedId)
            .eq('swiped_id', user.id)
            .inFilter('direction', ['like', 'super']);
        if ((matchRes as List).isNotEmpty) {
          // Create a Match!
          await client.from('matches').insert({
            'user1_id': user.id.compareTo(swipedId) < 0 ? user.id : swipedId,
            'user2_id': user.id.compareTo(swipedId) > 0 ? user.id : swipedId,
          });

          // Create a Chat channel
          final chatRes = await client.from('chats').insert({'is_group': false}).select('id').single();
          final chatId = chatRes['id'] as String;
          await client.from('chat_members').insert([
            {'chat_id': chatId, 'profile_id': user.id},
            {'chat_id': chatId, 'profile_id': swipedId},
          ]);
          return true; // Match happened!
        }
      }
    }
    return false;
  }

  Future<List<Chat>> getChats() async {
    final user = client.auth.currentUser;
    if (user != null) {
      final res = await client
          .from('chat_members')
          .select('chat_id, chats(*)')
          .eq('profile_id', user.id);
      
      List<Chat> chats = [];
      for (var item in res as List) {
        final chatData = item['chats'] as Map<String, dynamic>;
        final chatId = chatData['id'] as String;
        
        // Get other members
        final membersRes = await client
            .from('chat_members')
            .select('profiles(*)')
            .eq('chat_id', chatId)
            .neq('profile_id', user.id);
        
        List<Profile> otherMembers = (membersRes as List)
            .map((m) => Profile.fromJson(m['profiles'] as Map<String, dynamic>))
            .toList();

        chats.add(Chat.fromJson(chatData, members: otherMembers));
      }
      return chats;
    }
    return [];
  }

  Future<List<Message>> getMessages(String chatId) async {
    final res = await client
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);
    return (res as List).map((m) => Message.fromJson(m)).toList();
  }

  Future<Message> sendMessage(String chatId, String? content, {String? imageUrl}) async {
    final senderId = client.auth.currentUser!.id;
    final res = await client.from('messages').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'image_url': imageUrl,
    }).select().single();
    return Message.fromJson(res);
  }

  Future<List<TripRoom>> getTripRooms() async {
    final user = client.auth.currentUser;
    if (user != null) {
      final res = await client.from('trip_rooms').select();
      List<TripRoom> trips = [];
      for (var item in res as List) {
        final tripId = item['id'] as String;
        // Get members, expenses, itinerary
        final membersRes = await client.from('trip_members').select('profiles(*)').eq('trip_id', tripId);
        final members = (membersRes as List).map((m) => Profile.fromJson(m['profiles'])).toList();
        
        final expRes = await client.from('trip_expenses').select().eq('trip_id', tripId);
        final expenses = (expRes as List).map((e) => TripExpense.fromJson(e)).toList();

        final itiRes = await client.from('trip_itinerary').select().eq('trip_id', tripId).order('day_number');
        final itinerary = (itiRes as List).map((i) => TripItineraryItem.fromJson(i)).toList();

        trips.add(TripRoom.fromJson(item, members: members, expenses: expenses, itinerary: itinerary));
      }
      return trips;
    }
    return [];
  }

  Future<TripRoom> createTripRoom(TripRoom room) async {
    final res = await client.from('trip_rooms').insert(room.toJson()).select().single();
    // Insert creator as admin member
    await client.from('trip_members').insert({
      'trip_id': res['id'],
      'profile_id': room.creatorId,
      'role': 'admin',
    });
    return TripRoom.fromJson(res);
  }

  Future<TripExpense> addExpense(String tripId, String description, double amount) async {
    final paidBy = client.auth.currentUser!.id;
    final res = await client.from('trip_expenses').insert({
      'trip_id': tripId,
      'paid_by': paidBy,
      'amount': amount,
      'description': description,
    }).select().single();
    return TripExpense.fromJson(res);
  }

  Future<TripItineraryItem> addItineraryItem(String tripId, int dayNumber, String timeOfDay, String title, String description, String location) async {
    final res = await client.from('trip_itinerary').insert({
      'trip_id': tripId,
      'day_number': dayNumber,
      'time_of_day': timeOfDay,
      'title': title,
      'description': description,
      'location_name': location,
    }).select().single();
    return TripItineraryItem.fromJson(res);
  }

  Future<List<Story>> getStories() async {
    final res = await client.from('stories').select('*, profiles(*)').order('created_at', ascending: false);
    return (res as List).map((s) {
      final profile = Profile.fromJson(s['profiles']);
      return Story.fromJson(s, profile: profile);
    }).toList();
  }
}
