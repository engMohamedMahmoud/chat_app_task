import 'package:elarousi_task/model/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../firebase/firebase_db.dart';
import '../../chat_home_screen/chat_message_one_to_one.dart';

class ContactCardScreen extends StatelessWidget {
  final ChatUser chatUser;

  const ContactCardScreen({super.key, required this.chatUser});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(chatUser.name ?? "User"),
        subtitle: Text(

          chatUser.about!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
            onPressed: () {
              /// get room id
              List<String> members = [
                chatUser.id!,
                FirebaseAuth.instance.currentUser!.uid
              ]..sort(
                  (a, b) => a.compareTo(b),
                );

              FireDb()
                  .createChatRoom(chatUser.email!)
                  .then((value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatMessageOneToOne(
                                roomId: members.toString(),
                                chatUser: chatUser,
                              )))
              );
            },
            icon: const Icon(Iconsax.message)),
      ),
    );
  }
}
