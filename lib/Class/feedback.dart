class Feedbacks {
  final String id;
  final String eventId;
  final String userName;
  final String feedback;
  final DateTime createdDate;
  final bool confirm;

  Feedbacks({
    required this.id,
    required this.eventId,
    required this.userName,
    required this.feedback,
    required this.createdDate,
    required this.confirm,
  });

  factory Feedbacks.fromJson(Map<String, dynamic> json) {
    return Feedbacks(
      id: json['id'],
      eventId: json['eventId'],
      userName: json['userName'],
      feedback: json['feedback'],
      createdDate: DateTime.parse(json['createdDate']),
      confirm: json['confirm'],
    );
  }
}