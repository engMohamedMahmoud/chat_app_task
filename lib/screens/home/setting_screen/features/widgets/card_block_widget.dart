import 'package:elarousi_task/model/chat_user.dart';
import 'package:flutter/material.dart';
import 'unblock_dialog_widget.dart';

class CardBlockWidget extends StatelessWidget {
  final ChatUser user;
  const CardBlockWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(

      child: ExpansionTile(
        shape: const Border(),
        expandedCrossAxisAlignment:
        CrossAxisAlignment.start,
        title: Text("${user.name?[0].toUpperCase()}${user.name?.substring(1)}",
          maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium,),
        leading: user.image != "" ? CircleAvatar(backgroundImage: NetworkImage(user.image!),) :
        CircleAvatar(child: Text(user.name![0].toUpperCase()),),
        childrenPadding: const EdgeInsets.only(top: 10,right: 20, left: 20,bottom: 10),
        children: [
          Text(user.name!),
          Text(user.email!),
          Text(user.about!),

          TextButton(
              onPressed: () => showUnBlockBox(context, user),
              child:  Center(child: Text('Unblock ${user.name ?? ""}'),)),

        ],
      ),
    );
  }
}
