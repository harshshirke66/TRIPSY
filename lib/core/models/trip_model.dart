import 'package:tripsy/core/models/profile_model.dart';

class TripRoom {
  final String id;
  final String creatorId;
  final String title;
  final String? description;
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? budget;
  final String? coverImage;
  final DateTime createdAt;
  final List<Profile> members;
  final List<TripExpense> expenses;
  final List<TripItineraryItem> itinerary;

  TripRoom({
    required this.id,
    required this.creatorId,
    required this.title,
    this.description,
    required this.destination,
    this.startDate,
    this.endDate,
    this.budget,
    this.coverImage,
    required this.createdAt,
    this.members = const [],
    this.expenses = const [],
    this.itinerary = const [],
  });

  factory TripRoom.fromJson(
    Map<String, dynamic> json, {
    List<Profile> members = const [],
    List<TripExpense> expenses = const [],
    List<TripItineraryItem> itinerary = const [],
  }) {
    return TripRoom(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      destination: json['destination'] as String,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      budget: (json['budget'] as num?)?.toDouble(),
      coverImage: json['cover_image'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      members: members,
      expenses: expenses,
      itinerary: itinerary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'destination': destination,
      'start_date': startDate?.toIso8601String().substring(0, 10),
      'end_date': endDate?.toIso8601String().substring(0, 10),
      'budget': budget,
      'cover_image': coverImage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TripRoom copyWith({
    String? id,
    String? creatorId,
    String? title,
    String? description,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String? coverImage,
    DateTime? createdAt,
    List<Profile>? members,
    List<TripExpense>? expenses,
    List<TripItineraryItem>? itinerary,
  }) {
    return TripRoom(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      coverImage: coverImage ?? this.coverImage,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
      expenses: expenses ?? this.expenses,
      itinerary: itinerary ?? this.itinerary,
    );
  }
}

class TripExpense {
  final String id;
  final String tripId;
  final String paidBy;
  final double amount;
  final String description;
  final DateTime createdAt;

  TripExpense({
    required this.id,
    required this.tripId,
    required this.paidBy,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  factory TripExpense.fromJson(Map<String, dynamic> json) {
    return TripExpense(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      paidBy: json['paid_by'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'paid_by': paidBy,
      'amount': amount,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class TripItineraryItem {
  final String id;
  final String tripId;
  final int dayNumber;
  final String? timeOfDay;
  final String title;
  final String? description;
  final String? locationName;

  TripItineraryItem({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    this.timeOfDay,
    required this.title,
    this.description,
    this.locationName,
  });

  factory TripItineraryItem.fromJson(Map<String, dynamic> json) {
    return TripItineraryItem(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      dayNumber: json['day_number'] as int,
      timeOfDay: json['time_of_day'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      locationName: json['location_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'day_number': dayNumber,
      'time_of_day': timeOfDay,
      'title': title,
      'description': description,
      'location_name': locationName,
    };
  }
}
