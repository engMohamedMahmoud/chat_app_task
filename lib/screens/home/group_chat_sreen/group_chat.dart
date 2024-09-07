import 'package:elarousi_task/model/group_chat_model.dart';
import 'package:elarousi_task/screens/home/group_chat_sreen/create_group_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'widgets/card_group.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Chat"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CreateGroupRoom()));
        },
        child: const Icon(Iconsax.message_add_1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('groups')
                      .where('members',
                          arrayContains: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<GroupChatModel> groupsChatList = snapshot.data!.docs
                          .map(
                            (e) => GroupChatModel.fromJson(e.data()),
                          )
                          .toList()..sort((a, b) => b.lastMessageTime!.compareTo(a.lastMessageTime!),);
                      return ListView.builder(
                        itemCount: groupsChatList.length,
                        itemBuilder: ((context, index) {
                          return CardGroup(
                            groupChatModel: groupsChatList[index],
                          );
                        }),
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
