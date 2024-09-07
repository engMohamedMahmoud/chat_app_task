
import 'package:elarousi_task/firebase/firebase_db.dart';
import 'package:elarousi_task/model/group_chat_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../model/chat_user.dart';

class TypingChatTextWidget extends StatefulWidget {
  final String roomId;
  final ChatUser? chatUser;
  final GroupChatModel? groupChatModel;
  final TextEditingController textEditingController;

  const TypingChatTextWidget({super.key,  required this.roomId,  this.chatUser, required this.textEditingController, this.groupChatModel});

  @override
  State<TypingChatTextWidget> createState() => _TypingChatTextWidgetState();
}

class _TypingChatTextWidgetState extends State<TypingChatTextWidget> {



  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
        onPressed: () async {
          String userMessage = '';
          setState(() {
            userMessage = widget.textEditingController.text;
            widget.textEditingController.text = "";
            widget.textEditingController.clear();
            print('user message $userMessage');
          });
          if (userMessage != '') {
            if(widget.roomId != ''){
              await FireDb().sendMessage(widget.chatUser!.id!, userMessage, widget.roomId,widget.chatUser!,typeMessageData: 'text');
            }else{
              await FireDb().sendGroupMessage(userMessage, widget.groupChatModel!.id!, widget.groupChatModel!, 'text');
            }
          }
        },
        icon: const Icon(Iconsax.send_1)) ;
  }
}
