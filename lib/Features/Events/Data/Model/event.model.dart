class Event {
  final int id;
  final String name;
  final DateTime date;
  final String? imageUrl;
  final String details;
  final String location;
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
      date: DateTime.parse(json['date']),
      imageUrl: json['image'] as String?,
      details: json['details'],
      location: json['location'],
      creatorId: json['creator'],
      creatorName: json['creator_name'],
      attendeesCount: json['attendees_count'] ?? 0,
      isAttending: json['is_attending'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      attendeesList: (json['attendees_list'] as List<dynamic>?)
          ?.map((e) => EventAttendees.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'details': details,
      'location': location,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'details': details,
      'location': location,
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
    String? imageUrl,
    String? details,
    String? location,
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