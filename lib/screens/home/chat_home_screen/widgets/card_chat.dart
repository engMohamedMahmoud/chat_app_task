import 'package:elarousi_task/model/chat_room.dart';
import 'package:elarousi_task/model/chat_user.dart';
import 'package:elarousi_task/model/message_model.dart';
import 'package:elarousi_task/utils/date_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../chat_message_one_to_one.dart';

class CardChat extends StatelessWidget {
  final ChatRoom chatRoom;

  const CardChat({super.key, required this.chatRoom});

  @override
  Widget build(BuildContext context) {
    List members = chatRoom.members!.where((element) => element != FirebaseAuth.instance.currentUser!.uid,).toList();
    String userId = members.isEmpty? FirebaseAuth.instance.currentUser!.uid : members.first;

    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            return const Center(child: Text('Error...'),);
          }
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          if (snapshot.hasData) {
            ChatUser chatUser = ChatUser.fromJson(snapshot.data!.data()!);
            return Card(
              child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatMessageOneToOne(
                                  roomId: chatRoom.id!,
                                  chatUser: chatUser,
                                )));
                  },
                  leading: chatUser.image != ""? CircleAvatar(
                    backgroundImage: NetworkImage(chatUser.image!),
                  ):  CircleAvatar(child: Center(child: Text(chatUser.name![0].toUpperCase()),),),
                  title: Text(chatUser.name != "" ? chatUser.name! : "User",maxLines: 1,overflow: TextOverflow.ellipsis,),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(chatRoom.lastMessage! == ""
                            ? chatUser.about!
                            : chatRoom.lastMessage!,maxLines: 1,overflow: TextOverflow.ellipsis,),
                      ),
                      const Spacer(),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('chatRoom')
                            .doc(chatRoom.id)
                            .collection('messages')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            final unReadMsg = snapshot.data!.docs.map((e) => MessageModel.fromJson(e.data()),)
                                .where((element) => element.read == '',)
                                .where((element) => element.fromId != FirebaseAuth.instance.currentUser!.uid,);

                            return
                              unReadMsg.isNotEmpty
                                  ?
                              Badge(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                                label: Text("${unReadMsg.length}"),
                                largeSize: 30.0,
                              )
                                  :
                              Text(MyDateTime.dateTimeFormat(chatRoom.lastMessageTime!),)
                            ;
                          }else{
                            return Container();
                          }
                        },
                      )
                    ],
                  ),


              ),
            );
          }else{
            return Container();
          }
        });
  }
}
