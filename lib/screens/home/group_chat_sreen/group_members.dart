import 'package:elarousi_task/firebase/firebase_db.dart';
import 'package:elarousi_task/model/chat_user.dart';
import 'package:elarousi_task/screens/home/group_chat_sreen/group_edit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../model/group_chat_model.dart';

class GroupMembers extends StatefulWidget {
  final GroupChatModel groupChatModel;

  const GroupMembers({super.key, required this.groupChatModel});

  @override
  State<GroupMembers> createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.groupChatModel.admin!.contains(FirebaseAuth.instance.currentUser!.uid);
    print("admin ${widget.groupChatModel.admin!}, ${FirebaseAuth.instance.currentUser!.uid}");
    print("checkAdmin $isAdmin");

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.groupChatModel.name!} Members"),
        actions: [
          isAdmin
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditGroupRoomScreen(
                                  groupChatModel: widget.groupChatModel,
                                )));
                  },
                  icon: const Icon(Iconsax.user_edit))
              : Container()
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('id', whereIn: widget.groupChatModel.members)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<ChatUser> usersList = snapshot.data!.docs
                            .map(
                              (e) => ChatUser.fromJson(e.data()),
                            )
                            .toList();
                        return ListView.builder(
                            itemCount: usersList.length,
                            itemBuilder: (context, index) {
                              bool checkUserAdmin = widget.groupChatModel.admin!.contains(usersList[index].id);
                              return ListTile(
                                title: Text(usersList[index].name!),
                                subtitle: Text(widget.groupChatModel.admin!.contains(usersList[index].id) ?"Admin": "Member",
                                  style: TextStyle(
                                      fontWeight: checkUserAdmin

                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: checkUserAdmin
                                          ? Colors.blue
                                          : Colors.black),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    isAdmin && FirebaseAuth.instance.currentUser!.uid != usersList[index].id?
                                    IconButton(
                                        onPressed: () {

                                        },
                                        icon:  const Icon(Iconsax.user_tick) ): Container(),
                                    isAdmin && FirebaseAuth.instance.currentUser!.uid != usersList[index].id?
                                    IconButton(
                                        onPressed: () {
                                          FireDb().removeMemberOfGroupChat(widget.groupChatModel.id!, usersList[index].id!).then((value){
                                            setState(() {
                                              widget.groupChatModel.members!.remove(usersList[index].id);
                                            });
                                          });
                                        },
                                        icon:  const Icon(Iconsax.trash)) : Container(),
                                  ],
                                ),
                              );
                            });
                      } else {
                        return Container();
                      }
                    }))
          ],
        ),
      ),
    );
  }
}
