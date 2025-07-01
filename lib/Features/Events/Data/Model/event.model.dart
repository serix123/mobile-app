import 'package:online_reservation/Utils/utils.dart';

enum Location {
  BLOCK_1,
  BLOCK_2A,
  BLOCK_2A1,
  BLOCK_2B,
  BLOCK_2C,
  BLOCK_3,
  BLOCK_4,
  BLOCK_5,
  BLOCK_6A,
  BLOCK_6B,
  BLOCK_7,
  BLOCK_8,
  BLOCK_9,
  BLOCK_10,
  BLOCK_11,
  BLOCK_12,
}
extension LocationExtension on Location {
  String get displayName {
    switch (this) {
      case Location.BLOCK_1:
        return 'Block 1';
      case Location.BLOCK_2A:
        return 'Block 2A';
      case Location.BLOCK_2A1:
        return 'Block 2A1';
      case Location.BLOCK_2B:
        return 'Block 2B';
      case Location.BLOCK_2C:
        return 'Block 2C';
      case Location.BLOCK_3:
        return 'Block 3';
      case Location.BLOCK_4:
        return 'Block 4';
      case Location.BLOCK_5:
        return 'Block 5';
      case Location.BLOCK_6A:
        return 'Block 6A';
      case Location.BLOCK_6B:
        return 'Block 6B';
      case Location.BLOCK_7:
        return 'Block 7';
      case Location.BLOCK_8:
        return 'Block 8';
      case Location.BLOCK_9:
        return 'Block 9';
      case Location.BLOCK_10:
        return 'Block 10';
      case Location.BLOCK_11:
        return 'Block 11';
      case Location.BLOCK_12:
        return 'Block 12';
    }
  }

  String get jsonName => displayName; // use displayName directly

  static Location fromJson(String? json) {
    if (json == null) {
      throw ArgumentError('Location cannot be null');
    }
    switch (json) {
      case 'Block 1':
        return Location.BLOCK_1;
      case 'Block 2A':
        return Location.BLOCK_2A;
      case 'Block 2A1':
        return Location.BLOCK_2A1;
      case 'Block 2B':
        return Location.BLOCK_2B;
      case 'Block 2C':
        return Location.BLOCK_2C;
      case 'Block 3':
        return Location.BLOCK_3;
      case 'Block 4':
        return Location.BLOCK_4;
      case 'Block 5':
        return Location.BLOCK_5;
      case 'Block 6A':
        return Location.BLOCK_6A;
      case 'Block 6B':
        return Location.BLOCK_6B;
      case 'Block 7':
        return Location.BLOCK_7;
      case 'Block 8':
        return Location.BLOCK_8;
      case 'Block 9':
        return Location.BLOCK_9;
      case 'Block 10':
        return Location.BLOCK_10;
      case 'Block 11':
        return Location.BLOCK_11;
      case 'Block 12':
        return Location.BLOCK_12;
      default:
        throw ArgumentError('Unknown location: $json');
    }
  }
}

class Event {
  final int id;
  final String name;
  final DateTime date;
  final Duration duration;
  final String? imageUrl;
  final String details;
  final Location location;
  final int creatorId;
  final String creatorName;
  final int attendeesCount;
  final bool isAttending;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<EventAttendees>? attendeesList;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.duration,
    this.imageUrl,
    required this.details,
    required this.location,
    required this.creatorId,
    required this.creatorName,
    required this.attendeesCount,
    required this.isAttending,
    required this.createdAt,
    required this.updatedAt,
     this.attendeesList,
  });

  factory Event.fromJson(Map<String, dynamic> json) {

    return Event(
      id: json['id'],
      name: json['name'],
      date: Utils.parseAndRoundToQuarter(json['date']),
      imageUrl: json['image'] as String?,
      details: json['details'],
      location: LocationExtension.fromJson(json['location']),
      creatorId: json['creator'],
      creatorName: json['creator_name'],
      attendeesCount: json['attendees_count'] ?? 0,
      isAttending: json['is_attending'] ?? false,
      createdAt: Utils.parseAndRoundToQuarter(json['created_at']),
      updatedAt: Utils.parseAndRoundToQuarter(json['updated_at']),
      attendeesList: (json['attendees_list'] as List<dynamic>?)
          ?.map((e) => EventAttendees.fromJson(e))
          .toList(),
      duration: Utils.parseDuration(json['duration']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'duration': Utils.durationToString(duration),
      'details': details,
      'location': location.jsonName,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'duration': Utils.durationToString(duration),
      'details': details,
      'location': location.jsonName,
      'creator': creatorId,
      'creator_name': creatorName,
      'attendees_count': attendeesCount,
      'is_attending': isAttending,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Event copyWith({
    int? id,
    String? name,
    DateTime? date,
    Duration? duration,
    String? imageUrl,
    String? details,
    Location? location,
    int? creatorId,
    String? creatorName,
    int? attendeesCount,
    bool? isAttending,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<EventAttendees>? attendeesList,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      imageUrl: imageUrl ?? this.imageUrl,
      details: details ?? this.details,
      location: location ?? this.location,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      isAttending: isAttending ?? this.isAttending,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attendeesList: attendeesList ?? this.attendeesList,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, name: $name, date: $date, details: $details, '
        'location: $location, creatorId: $creatorId, creatorName: $creatorName, '
        'attendeesCount: $attendeesCount, isAttending: $isAttending, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

class EventAttendees{
  final String fullName;
  final String? email;
  final String? contactNumber;

  EventAttendees({
    required this.fullName,
    this.contactNumber,
    this.email
  });

  factory EventAttendees.fromJson(Map<String, dynamic> json) {

    return EventAttendees(
      fullName: json['full_name'] ?? "Resident User",
      contactNumber: json['contact_number'] as String?,
      email: json['email'] as String?,
    );
  }
}