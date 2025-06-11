class Comment {
  final int? id;
  final int issueId;
  final String comment;
  final int? userId;
  final String? userEmail;
  final String? userFullName;
  final DateTime? createdAt;

  Comment({
    this.id,
    required this.issueId,
    required this.comment,
    this.userId,
    this.userEmail,
    this.userFullName,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      issueId: json['issue'],
      userId: json['user'],
      userEmail: json['user_email'],
      userFullName: json['user_full_name'],
      comment: json['comment'] ?? "",
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issue': issueId,
      'comment': comment,
    };
  }
}
