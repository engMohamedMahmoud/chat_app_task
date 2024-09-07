class ChatRoom {
  String? id;
  List? members;
  String? lastMessage;
  String? lastMessageTime;
  String? createdAt;
  bool? isBlocked;

  ChatRoom({
    required this.id,
    required this.members,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
    required this.isBlocked
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
        id: json['id'] ?? "",
        members: json['members'],
        lastMessage: json['last_message'],
        lastMessageTime: json['last_message_time'],
        createdAt: json['created_at'],
      isBlocked: json['is_blocked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'members': members,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'created_at': createdAt,
      'is_blocked':isBlocked
    };
  }
}
