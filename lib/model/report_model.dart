class ReportModel {
  String? id;
  String? reportedBy;
  String? messageId;
  String? userId;
  String? createdAt;

  ReportModel({
    required this.id,
    required this.reportedBy,
    required this.messageId,
    required this.userId,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
        id: json['id'] ?? "",
        reportedBy: json['reported_by'],
        messageId: json['message_id'],
        userId: json['user_id'],
        createdAt: json['created_at']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reported_by': reportedBy,
      'message_id': messageId,
      'user_id': userId,
      'created_at': createdAt,
    };
  }
}
