

import 'package:elarousi_task/model/chat_user.dart';
import 'package:elarousi_task/model/message_model.dart';
import 'package:elarousi_task/screens/home/chat_home_screen/widgets/alslam_message_widget.dart';
import 'package:elarousi_task/screens/home/chat_home_screen/widgets/bottom_chat_room_card_textfield.dart';
import 'package:elarousi_task/screens/home/chat_home_screen/widgets/message_chat_component.dart';
import 'package:elarousi_task/screens/home/chat_home_screen/widgets/typing_chat_text_widget.dart';
import 'package:elarousi_task/screens/home/chat_home_screen/widgets/voice_chat_btn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import '../../../firebase/firebase_db.dart';
import '../../../provider/provider_app.dart';
import '../../../utils/date_time.dart';

class ChatMessageOneToOne extends StatefulWidget {
  final String roomId;
  final ChatUser chatUser;

  const ChatMessageOneToOne(
      {super.key, required this.roomId, required this.chatUser});

  @override
  State<ChatMessageOneToOne> createState() => _ChatMessageOneToOneState();
}

class _ChatMessageOneToOneState extends State<ChatMessageOneToOne> {
  List<String> selectedMsg = [];
  List<String> copyMsg = [];
  TextEditingController textEditingController = TextEditingController();
  final AudioRecorder record = AudioRecorder();


  Future<void> handleSharedData() async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        textEditingController.text = data.text!;
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // handleSharedData();
    textEditingController.addListener((){
      setState(() {

        print("addListener ${textEditingController.text}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderApp>(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chatUser.name != "" ? widget.chatUser.name! : "User",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.chatUser.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data!.data()!['online']
                          ? "Online"
                          : 'Last seen at ${MyDateTime.dateTimeFunc(widget.chatUser.lastActivated!)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    );
                  } else {
                    return Container();
                  }
                })
          ],
        ),
        actions: [
          selectedMsg.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    FireDb()
                        .deleteMessage(
                            widget.roomId, selectedMsg, widget.chatUser)
                        .then((value) {
                      setState(() {
                        selectedMsg = [];
                        copyMsg = [];
                      });
                    });
                  },
                  icon: const Icon(Iconsax.trash))
              : Container(),
          copyMsg.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: copyMsg.join(' \n')))
                        .then((value) {});
                    copyMsg.clear();
                    selectedMsg.clear();
                  },
                  icon: const Icon(Iconsax.copy))
              : Container(),

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("chatRoom").doc(widget.roomId).snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              bool isBlocked = snapshot.data!["is_blocked"];
               return Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('chatRoom')
                            .doc(widget.roomId)
                            .collection('messages')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<MessageModel> messagesList = snapshot.data!.docs
                                .map((e) => MessageModel.fromJson(e.data()),).toList()
                              ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!),);

                            return messagesList.isNotEmpty
                                ? ListView.builder(
                              itemCount: messagesList.length,
                              reverse: true,
                              itemBuilder: (context, index) {
                                String newDate = '';
                                bool isTheSameDate = false;
                                if((index == 0 && messagesList.length == 1) || index == messagesList.length -1){
                                  newDate = MyDateTime.dateTimeFunc(messagesList[index].createdAt!);
                                }else{
                                  final DateTime date = MyDateTime.dateFormat(messagesList[index].createdAt!);
                                  final DateTime preDate = MyDateTime.dateFormat(messagesList[index + 1].createdAt!);

                                  isTheSameDate = date.isAtSameMomentAs(preDate);
                                  newDate = isTheSameDate ? "" : MyDateTime.dateTimeFunc(messagesList[index].createdAt!);
                                }


                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedMsg.isNotEmpty
                                          ? selectedMsg.contains(
                                          messagesList[index].id)
                                          ? selectedMsg.remove(
                                          messagesList[index].id)
                                          : selectedMsg
                                          .add(messagesList[index].id!)
                                          : null;

                                      copyMsg.isNotEmpty
                                          ? copyMsg.contains(
                                          messagesList[index].msg)
                                          ? copyMsg.remove(
                                          messagesList[index].msg)
                                          : copyMsg
                                          .add(messagesList[index].msg!)
                                          : null;
                                    });
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      /// selected messages
                                      selectedMsg
                                          .contains(messagesList[index].id)
                                          ? selectedMsg
                                          .remove(messagesList[index].id)
                                          : selectedMsg
                                          .add(messagesList[index].id!);

                                      /// copy message
                                      messagesList[index].type == "text"
                                          ? copyMsg.contains(
                                          messagesList[index].msg)
                                          ? copyMsg.remove(
                                          messagesList[index].msg)
                                          : copyMsg
                                          .add(messagesList[index].msg!)
                                          : null;
                                    });
                                  },
                                  child: Column(
                                    children: [



                                      if(newDate != "")
                                        Center(child: Text(newDate),),
                                      MessageChatComponent(
                                        selected: selectedMsg.contains(messagesList[index].id),
                                        roomId: widget.roomId,
                                        index: index,
                                        messageModel: messagesList[index],
                                        lastMessageModel: messagesList.first,
                                        userId: widget.chatUser.id!,
                                        isBlocked: isBlocked,
                                      ),
                                      // if (provider.isLoading == true && index == 0)
                                        // LoaderImageWidget(isMessageFromMe: messagesList[index].fromId == FirebaseAuth.instance.currentUser!.uid,createdAt: messagesList[index].createdAt!,),
                                    ],
                                  ),


                                );
                              },
                            )
                                : AlslamMessageWidget(chatUser: widget.chatUser, roomId: widget.roomId);
                          } else {
                            return Container();
                          }
                        }),
                  ),
                  isBlocked == false?
                  Row(
                    children: [

                      Expanded(
                          child: BottomChatRoomCardTextField(
                            textEditingController: textEditingController,
                            chatRoomId: widget.roomId,
                            chatUser: widget.chatUser,
                            provider: provider,
                          )),

                      textEditingController.text.isNotEmpty?
                      TypingChatTextWidget(roomId: widget.roomId, chatUser: widget.chatUser,textEditingController: textEditingController,) :
                      VoiceChatBtn(provider: provider,roomId: widget.roomId,chatUser: widget.chatUser,record: record,)
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text("You're blocked", style: Theme.of(context).textTheme.titleSmall,),),
                      )
                    ],
                  )
                ],
              );
            }else{
              return Container();
            }
          }
        ),
      ),
    );
  }


}
