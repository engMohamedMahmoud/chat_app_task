import 'dart:async';
import 'package:elarousi_task/model/chat_room.dart';
import 'package:elarousi_task/screens/home/shared_message_data/shared_data_screen.dart';
import 'package:elarousi_task/screens/home/chat_home_screen/widgets/bottom_sheet_invite_friend_create_new_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_handler/share_handler.dart';
import 'widgets/card_chat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat"),),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
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
                          itemBuilder: ((context, index) {
                            return CardChat(
                              chatRoom: rooms[index],
                            );
                          }),
                        );
                      } else {
                        return Container();
                      }
                    })),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController editingControllerEmail = TextEditingController();
          showBottomSheetCreateNewChatRoom(context, editingControllerEmail, "Create Chat Room");
        }, child: const Icon(Iconsax.message_add),
      ),
    );
  }
}
