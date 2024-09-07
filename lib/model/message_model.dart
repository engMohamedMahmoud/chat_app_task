class MessageModel {
  String? id;
  String? toId;
  String? fromId;
  String? msg;
  String? type;
  String? createdAt;
  String? read;

  MessageModel({
    required this.id,
    required this.toId,
    required this.fromId,
    required this.msg,
    required this.type,
    required this.createdAt,
    required this.read,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
        id: json['id'] ?? "",
        toId: json['to_id'],
        fromId: json['from_id'],
        msg: json['msg'],
        type: json['type'],
        read: json['read'],
        createdAt: json['created_at']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'to_id': toId,
      'from_id': fromId,
      'msg': msg,
      'type': type,
      'read': read,
      'created_at': createdAt,
    };
  }
}
