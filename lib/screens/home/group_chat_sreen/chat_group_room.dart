import 'package:elarousi_task/screens/home/group_chat_sreen/group_members.dart';
import 'package:elarousi_task/widgets/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../../firebase/firebase_db.dart';
import '../../../model/group_chat_model.dart';
import '../../../model/message_model.dart';
import '../../../provider/provider_app.dart';
import '../../../utils/date_time.dart';
import '../chat_home_screen/widgets/typing_chat_text_widget.dart';
import '../chat_home_screen/widgets/voice_chat_btn.dart';
import 'widgets/bottom_group_chat_textfield.dart';
import 'widgets/chat_group_component.dart';

class ChatMessageGroupScreen extends StatefulWidget {
  final GroupChatModel groupChatModel;

  const ChatMessageGroupScreen({super.key, required this.groupChatModel});

  @override
  State<ChatMessageGroupScreen> createState() => _ChatMessageGroupScreenState();
}

class _ChatMessageGroupScreenState extends State<ChatMessageGroupScreen> {
  int messageListLength = 6;
  String groupName = "Developers";
  List<String> selectedMsg = [];
  List<String> copyMsg = [];
  bool isLoading = false;

  TextEditingController textEditingController = TextEditingController();

  final AudioRecorder record = AudioRecorder();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
              widget.groupChatModel.name!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('id', whereIn: widget.groupChatModel.members)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List members = [];
                    for (var element in snapshot.data!.docs) {
                      members.add(element.data()['name']);
                    }
                    return Text(
                      members.join(',').toString(),
                      style: Theme.of(context).textTheme.labelLarge,
                    );
                  } else {
                    return Container();
                  }
                })
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupMembers(
                              groupChatModel: widget.groupChatModel,
                            )));
              },
              icon: const Icon(Iconsax.user)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        child: Column(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.groupChatModel.id)
                    .collection('messages')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<MessageModel> messagesList = snapshot.data!.docs
                        .map(
                          (e) => MessageModel.fromJson(e.data()),
                        )
                        .toList()
                      ..sort(
                        (a, b) => b.createdAt!.compareTo(a.createdAt!),
                      );

                    return Expanded(
                      child: messagesList.isNotEmpty
                          ? ListView.builder(
                              itemCount: messagesList.length,
                              reverse: true,
                              itemBuilder: (context, index) {
                                String newDate = '';
                                bool isTheSameDate = false;
                                if ((index == 0 && messagesList.length == 1) ||
                                    index == messagesList.length - 1) {
                                  newDate = MyDateTime.dateTimeFunc(
                                      messagesList[index].createdAt!);
                                } else {
                                  final DateTime date = MyDateTime.dateFormat(
                                      messagesList[index].createdAt!);
                                  final DateTime preDate =
                                      MyDateTime.dateFormat(
                                          messagesList[index + 1].createdAt!);

                                  isTheSameDate =
                                      date.isAtSameMomentAs(preDate);
                                  newDate = isTheSameDate
                                      ? ""
                                      : MyDateTime.dateTimeFunc(
                                          messagesList[index].createdAt!);
                                }
                                return Column(
                                  children: [
                                    if (newDate != "")
                                      Center(
                                        child: Text(newDate),
                                      ),
                                    ChatGroupComponent(
                                      index: index,
                                      messageModel: messagesList[index],groupId: widget.groupChatModel.id!,
                                      lastMessageModel: messagesList.first,
                                    ),
                                  ],
                                );
                              },
                            )
                          : Center(
                              child: GestureDetector(
                                onTap: () => FireDb().sendGroupMessage(
                                    "alslam 3lykm 👋",
                                    widget.groupChatModel.id!, widget.groupChatModel,
                                    'text'),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "👋",
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium,
                                        ),
                                        heightSpace,
                                        Text(
                                          "alslam 3lykm ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    );
                  } else {
                    return Container();
                  }
                }),
            Row(
              children: [
                Expanded(
                    child: BottomGroupChatTextField(
                  textEditingController: textEditingController,
                  groupChatModel: widget.groupChatModel,
                  provider: provider,
                )),

                textEditingController.text.isNotEmpty?
                TypingChatTextWidget(roomId: '',groupChatModel: widget.groupChatModel,textEditingController: textEditingController,) :
                VoiceChatBtn(provider: provider,roomId: '',groupChatModel: widget.groupChatModel,record: record,)




              ],
            )
          ],
        ),
      ),
    );
  }
}
