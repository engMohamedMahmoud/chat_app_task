import 'package:elarousi_task/model/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_handler/share_handler.dart';
import 'card_send_msg.dart';

class ListviewMembers extends StatelessWidget {
  final String sharedData;
  final SharedMedia media;
  const ListviewMembers({super.key, required this.sharedData, required this.media});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('chatRoom').
            where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid).where('is_blocked',isEqualTo: false).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<ChatRoom> rooms = snapshot.data!.docs.map((e) => ChatRoom.fromJson(e.data()),).toList()
                  ..sort((a, b) => b.lastMessageTime!.compareTo(a.lastMessageTime!),);
                return ListView.builder(
                  itemCount: rooms.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: ((context, index) {
                    return CardSendMsg(
                        chatRoom: rooms[index],
                        sharedData: sharedData,
                      media: media,
                      index:index

                    );
                  }),
                );
              } else {
                return Container();
              }
            }));
  }
}
