import 'package:cached_network_image/cached_network_image.dart';
import 'package:elarousi_task/utils/date_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:link_text/link_text.dart';
import 'package:url_launcher/link.dart';

import '../../../../model/message_model.dart';
import '../../../../utils/photo_view_screen.dart';
import '../../chat_home_screen/widgets/display_voice_note_widget.dart';
import '../../chat_home_screen/widgets/message_options_widget.dart';
import 'edit_message_widget.dart';

class ChatGroupComponent extends StatefulWidget {
  final int index;
  final MessageModel messageModel;
  final String groupId;
  final MessageModel lastMessageModel;
  const ChatGroupComponent({super.key, required this.index, required this.messageModel, required this.groupId, required this.lastMessageModel});

  @override
  State<ChatGroupComponent> createState() => _ChatGroupComponentState();
}

class _ChatGroupComponentState extends State<ChatGroupComponent> {
  @override
  Widget build(BuildContext context) {


      bool isMessageFromMe = widget.messageModel.fromId == FirebaseAuth.instance.currentUser!.uid;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // color: widget.selected? Colors.grey.withOpacity(0.2) : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment:
        isMessageFromMe  ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          isMessageFromMe
              ? widget.messageModel.type == 'text'? IconButton(
              onPressed: () {
                TextEditingController textEditingController = TextEditingController();
                setState(() {
                  textEditingController.text = widget.messageModel.msg!;
                  showMessageUpdateDialog(context, widget.groupId, widget.messageModel.id!, textEditingController, true, widget.lastMessageModel);
                });

              }, icon: const Icon(Iconsax.message_edit,)) : Container()
              : const SizedBox(),
          Card(
            margin: const EdgeInsets.only(top: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isMessageFromMe ? 16 : 0),
                  bottomRight: Radius.circular(isMessageFromMe ? 0 : 16),
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                )),
            color: isMessageFromMe
                ? Theme.of(context).colorScheme.background.withOpacity(0.2)
                : Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width / 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    !isMessageFromMe?
                    StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('users').doc(widget.messageModel.fromId).snapshots(),
                      builder: (context, snapshot) {
                        return snapshot.hasData? Text(snapshot.data!.data()!['name'], style: TextStyle(color: Theme.of(context).colorScheme.background, fontWeight: FontWeight.bold),) : Container();
                      }
                    ): const SizedBox(),
                    const SizedBox(height: 4,),

                    widget.messageModel.type == 'image'
                        ? GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PhotoViewScreen(
                                  image: widget.messageModel.msg!))),
                      child: CachedNetworkImage(
                        imageUrl: widget.messageModel.msg!,
                        placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                      ),
                    )
                        : widget.messageModel.type == 'voice' ? DisplayVoiceNoteWidget(voiceMessage: widget.messageModel.msg!)
                        : LinkText(widget.messageModel.msg!),
                    const SizedBox(height: 5,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isMessageFromMe ?   Icon(
                          Iconsax.tick_circle,
                          color:  widget.messageModel.read == ""? Colors.grey: Colors.blueAccent,
                          size: 18,
                        ) : const SizedBox(),
                        SizedBox(width: isMessageFromMe ? 6 : 0,),
                        Text(MyDateTime.dateTimeFormat(widget.messageModel.createdAt!).toLowerCase(), style: Theme.of(context).textTheme.labelSmall,),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

          !isMessageFromMe? IconButton(
              onPressed: () =>showOptions(context, widget.messageModel.id!,  widget.messageModel.fromId!, true),
              icon: const Icon(
                Iconsax.setting_2,
              ))
              : const SizedBox(),

        ],
      ),
    );
  }
}
