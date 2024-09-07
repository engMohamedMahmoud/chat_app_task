import 'package:cached_network_image/cached_network_image.dart';
import 'package:elarousi_task/firebase/firebase_db.dart';
import 'package:elarousi_task/model/message_model.dart';
import 'package:elarousi_task/screens/home/chat_home_screen/widgets/display_voice_note_widget.dart';
import 'package:elarousi_task/screens/home/chat_home_screen/widgets/message_options_widget.dart';
import 'package:elarousi_task/utils/photo_view_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:link_text/link_text.dart';
import 'package:url_launcher/link.dart';
import '../../../../widgets/components.dart';
import '../../group_chat_sreen/widgets/edit_message_widget.dart';

class MessageChatComponent extends StatefulWidget {
  final MessageModel messageModel;
  final MessageModel lastMessageModel;
  final String roomId;
  final int index;
  final bool selected;
  final String userId;
  final bool isBlocked;

  const MessageChatComponent(
      {super.key,
      required this.index,
      required this.messageModel,
      required this.roomId,
      required this.selected,
      required this.lastMessageModel, required this.userId, required this.isBlocked});

  @override
  State<MessageChatComponent> createState() => _MessageChatComponentState();
}

class _MessageChatComponentState extends State<MessageChatComponent> {

  @override
  void initState() {
    /// to check read message
    if (widget.messageModel.toId == FirebaseAuth.instance.currentUser!.uid) {
      FireDb().readMessage(widget.roomId, widget.messageModel.id!);
    }
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    bool isMessageFromMe = widget.messageModel.fromId == FirebaseAuth.instance.currentUser!.uid;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
            widget.selected ? Colors.grey.withOpacity(0.2) : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment:
            isMessageFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          isMessageFromMe
              ? widget.messageModel.type == 'text' && widget.isBlocked == false
                  ? IconButton(
                      onPressed: () {
                        TextEditingController textEditingController =
                            TextEditingController();
                        setState(() {
                          textEditingController.text = widget.messageModel.msg!;
                          showMessageUpdateDialog(
                              context,
                              widget.roomId,
                              widget.messageModel.id!,
                              textEditingController,
                              false,
                              widget.lastMessageModel);
                        });
                      },
                      icon: const Icon(
                        Iconsax.message_edit,
                      ))
                  : Container()
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
                constraints: BoxConstraints(maxWidth:  MediaQuery.sizeOf(context).width / 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 0),
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
                        : widget.messageModel.type == 'voice' ?
                    DisplayVoiceNoteWidget(voiceMessage: widget.messageModel.msg!,key: ValueKey(widget.messageModel.id),)
                        : LinkText(widget.messageModel.msg!),
                    const SizedBox(height: 5,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isMessageFromMe
                            ? Icon(
                                Iconsax.tick_circle,
                                color: widget.messageModel.read == ""
                                    ? Colors.grey
                                    : Colors.blueAccent,
                                size: 18,
                              )
                            : const SizedBox(),
                        SizedBox(
                          width: isMessageFromMe ? 6 : 0,
                        ),
                        Text(
                          DateFormat.jm()
                              .format(DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(widget.messageModel.createdAt!)))
                              .toLowerCase(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          !isMessageFromMe && widget.isBlocked == false? IconButton(
              onPressed: () =>showOptions(context, widget.messageModel.id!,  widget.userId, false),
              icon: const Icon(
                Iconsax.setting_2,
              ))
              : const SizedBox(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    ImageCache().clear();
  }
}
