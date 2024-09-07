import 'package:elarousi_task/model/group_chat_model.dart';
import 'package:elarousi_task/utils/date_time.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../chat_group_room.dart';

class CardGroup extends StatelessWidget {
  final GroupChatModel groupChatModel;
  const CardGroup({
    super.key, required this.groupChatModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatMessageGroupScreen(
                      groupChatModel: groupChatModel,
                        )));
          },
          leading:  CircleAvatar(
            child: Text(groupChatModel.name![0].toUpperCase()),
          ),
          title:  Text(groupChatModel.name ?? "Group Name"),
          subtitle:  Text(groupChatModel.lastMessage == ""? "Send First Message" : groupChatModel.lastMessage!,maxLines: 1,overflow: TextOverflow.ellipsis,),
        trailing: Text(MyDateTime.dateTimeFunc(groupChatModel.lastMessageTime!)),
          // trailing: const Badge(
          //   padding: EdgeInsets.symmetric(horizontal: 10.0),
          //   label: Text("3"),
          //   largeSize: 30.0,
          // )
      ),
    );
  }
}
