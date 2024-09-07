class GroupChatModel {
  String? id;
  String? name;
  String? image;
  List? members;
  List? admin;
  String? lastMessage;
  String? lastMessageTime;
  String? createdAt;


  GroupChatModel({
    required this.id,
    required this.name,
    required this.image,
    required this.members,
    required this.admin,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,

  });

  factory GroupChatModel.fromJson(Map<String, dynamic> json) {
    return GroupChatModel(
        id: json['id'] ?? "",
        name: json['name'] ?? "",
        image: json['image'] ?? "",
        members: json['members'] ?? [],
        admin: json['admin'] ?? [],
        lastMessage: json['last_message'] ?? "",
        lastMessageTime: json['last_message_time'] ?? "",
        createdAt: json['created_at'],
    );

  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'members': members,
      'admin': admin,
      'last_message': lastMessage,
      'last_message_time':lastMessageTime,
      'created_at': createdAt
    };
  }
}
