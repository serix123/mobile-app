class Event {
  final int id;
  final String name;
  final DateTime date;
  final String details;
  final String location;
  final int creatorId;
  final String creatorName;
  final int attendeesCount;
  final bool isAttending;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> attendeesList;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.details,
    required this.location,
    required this.creatorId,
    required this.creatorName,
    required this.attendeesCount,
    required this.isAttending,
    required this.createdAt,
    required this.updatedAt,
    required this.attendeesList,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      details: json['details'],
      location: json['location'],
      creatorId: json['creator'],
      creatorName: json['creator_name'],
      attendeesCount: json['attendees_count'] ?? 0,
      isAttending: json['is_attending'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      attendeesList: List<String>.from(json['attendees_list'] ?? []),
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
    String? details,
    String? location,
    int? creatorId,
    String? creatorName,
    int? attendeesCount,
    bool? isAttending,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? attendeesList,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
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

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;
  //
  //   return other is Event &&
  //       other.id == id &&
  //       other.name == name &&
  //       other.date == date &&
  //       other.details == details &&
  //       other.location == location &&
  //       other.creatorId == creatorId &&
  //       other.creatorName == creatorName &&
  //       other.attendeesCount == attendeesCount &&
  //       other.isAttending == isAttending &&
  //       other.createdAt == createdAt &&
  //       other.updatedAt == updatedAt;
  // }
  //
  // @override
  // int get hashCode {
  //   return id.hashCode ^
  //   name.hashCode ^
  //   date.hashCode ^
  //   details.hashCode ^
  //   location.hashCode ^
  //   creatorId.hashCode ^
  //   creatorName.hashCode ^
  //   attendeesCount.hashCode ^
  //   isAttending.hashCode ^
  //   createdAt.hashCode ^
  //   updatedAt.hashCode;
  // }
}