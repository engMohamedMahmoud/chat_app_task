import 'package:elarousi_task/firebase/firebase_db.dart';
import 'package:elarousi_task/widgets/custom_textformfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../model/chat_user.dart';
import '../../../model/group_chat_model.dart';
import 'group_chat.dart';

class EditGroupRoomScreen extends StatefulWidget {
  final GroupChatModel groupChatModel;

  const EditGroupRoomScreen({super.key, required this.groupChatModel});

  @override
  State<EditGroupRoomScreen> createState() => _EditGroupRoomScreenState();
}

class _EditGroupRoomScreenState extends State<EditGroupRoomScreen> {
  TextEditingController textEditingControllerGroupName =
      TextEditingController();
  List members = [];
  List myContactIds = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingControllerGroupName.text = widget.groupChatModel.name!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          FireDb()
              .editGroup(widget.groupChatModel.id!,
                  textEditingControllerGroupName.text, members)
              .then((value){
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
          });
        },
        label: const Text("Done"),
        icon: const Icon(Iconsax.tick_circle),
      ),
      appBar: AppBar(
        title: Text("Edit ${widget.groupChatModel.name!} Group"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                        ),
                        Positioned(
                          right: -10,
                          bottom: -10,
                          child: IconButton.filled(
                              onPressed: () {},
                              icon: const Icon(Icons.add_a_photo)),
                        )
                      ],
                    )),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                    child: CustomTextformfield(
                        textInputType: TextInputType.text,
                        isPassword: false,
                        labelName: "Group Name",
                        widget: const Icon(Iconsax.user_octagon),
                        editingController: textEditingControllerGroupName))
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(),
            const SizedBox(
              height: 16,
            ),
             Row(
              children: [const Text("Members"), const Spacer(), Text(members.length.toString())],
            ),
            Expanded(
                child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  myContactIds = snapshot.data!.data()!['my_users'];
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('id',
                            whereIn: myContactIds.isEmpty ? [''] : myContactIds)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final List<ChatUser> chatUsersList = snapshot.data!.docs
                            .map(
                              (e) => ChatUser.fromJson(e.data()),
                            )
                            .where(
                              (element) =>
                                  element.id! !=
                                  FirebaseAuth.instance.currentUser!.uid,
                            )
                            .where(
                              (element) => !widget.groupChatModel.members!
                                  .contains(element.id),
                            )
                            .toList()
                          ..sort(
                            (a, b) => a.name!.compareTo(b.name!),
                          );
                        return ListView.builder(
                            itemCount: chatUsersList.length,
                            itemBuilder: (context, index) {
                              return CheckboxListTile(
                                  checkboxShape: const CircleBorder(),
                                  title: Text(chatUsersList[index].name!),
                                  value:
                                      members.contains(chatUsersList[index].id),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value!) {
                                        members.add(chatUsersList[index].id!);
                                      } else {
                                        members
                                            .remove(chatUsersList[index].id!);
                                      }
                                    });
                                  });
                            });
                      } else {
                        return Container();
                      }
                    },
                  );
                } else {
                  return Container();
                }
              },
            ))
          ],
        ),
      ),
    );
  }
}
