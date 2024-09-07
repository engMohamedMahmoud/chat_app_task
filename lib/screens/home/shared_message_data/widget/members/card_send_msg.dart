import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:share_handler/share_handler.dart';
import '../../../../../firebase/firebase_db.dart';
import '../../../../../firebase/firebase_storage.dart';
import '../../../../../model/chat_room.dart';
import '../../../../../model/chat_user.dart';
import '../../../../../provider/member_provider.dart';

class CardSendMsg extends StatelessWidget {
  final ChatRoom chatRoom;
  final String sharedData;
  final SharedMedia media;
  final int index;

  const CardSendMsg({super.key, required this.chatRoom, required this.sharedData, required this.media, required this.index});

  @override
  Widget build(BuildContext context) {
    List members = chatRoom.members!.where((element) => element != FirebaseAuth.instance.currentUser!.uid,).toList();
    String userId = members.isEmpty? FirebaseAuth.instance.currentUser!.uid : members.first;
    final provider = Provider.of<MemberProvider>(context);

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
                leading: chatUser.image != ""? CircleAvatar(
                  backgroundImage: NetworkImage(chatUser.image!),
                ):  CircleAvatar(child: Center(child: Text(chatUser.name![0].toUpperCase()),),),
                title: Text(chatUser.name != "" ? chatUser.name! : "User",
                  maxLines: 1,overflow: TextOverflow.ellipsis,),

                trailing: Consumer<MemberProvider>(
                    builder: (context, loadingProvider, child) {
                      bool isLoading = loadingProvider.loadingIndex == index;
                      return isLoading? const CircularProgressIndicator():
                      IconButton(onPressed: () async {

                        provider.setLoadingIndex(index);
                        if(sharedData.isNotEmpty){
                          FireDb().sendMessage(chatUser.id!, sharedData, chatRoom.id!,chatUser, typeMessageData: 'text').
                          then((value) => provider.resetLoadingIndex(),);
                        }else{


                          for(int i=0; i < media.attachments!.length; i++){
                            if (media.attachments![i]?.type == SharedAttachmentType.image) {
                              FireStorage().sendMessageFile(file: File(media.attachments![i]!.path),
                                  roomId: chatRoom.id!, chatUserId: chatUser.id!,chatUser: chatUser).then((value) => provider.resetLoadingIndex(),);
                            }
                          }
                          

                          await DefaultCacheManager().emptyCache();




                        }

                      }, icon: const Icon(Icons.send));
                    }
                ),

              ),
            );
          }else{
            return Container();
          }
        });
  }
}
