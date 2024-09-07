import 'package:elarousi_task/model/group_chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_handler/share_handler.dart';
import 'groups_sent_card_item.dart';

class ListviewGroups extends StatelessWidget {
  final String sharedData;
  final SharedMedia media;
  const ListviewGroups(this.sharedData, {super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('groups').where('members',
              arrayContains: FirebaseAuth.instance.currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<GroupChatModel> groupsChatList = snapshot.data!.docs.map(
                    (e) => GroupChatModel.fromJson(e.data()),
              ).toList()..sort((a, b) => b.lastMessageTime!.compareTo(a.lastMessageTime!),);
              return ListView.builder(
                itemCount: groupsChatList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: ((context, index) {
                  return GroupsSentList(
                    index: index, groupChatModel: groupsChatList[index], sharedData:sharedData, media: media,);
                }),
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
