import 'package:elarousi_task/screens/home/contacts_screen/widgets/bottom_sheet_Contact.dart';
import 'package:elarousi_task/screens/home/contacts_screen/widgets/contact_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../model/chat_user.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  bool searched = false;
  TextEditingController searchController = TextEditingController();
  List myContactIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          searched
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      searched = false;
                      searchController.text = "";
                    });
                  },
                  icon: const Icon(Iconsax.close_circle))
              : IconButton(
                  onPressed: () {
                    setState(() {
                      searched = true;
                    });
                  },
                  icon: const Icon(Iconsax.search_normal))
        ],
        title: searched
            ? Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: searchController,
                    autofocus: true,
                    onChanged: (value){
                      setState(() {
                        searchController.text = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Search by name",
                      // border: InputBorder.
                    ),
                  ))
                ],
              )
            : const Text("My Contacts"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).
                  collection('blockUsers').snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      final blockedUserId = snapshot.data!.docs.map((e) => e.id,).toList();
                      return StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            myContactIds = snapshot.data!.data()!['my_users'] ?? [];
                            List<String> finalList = List.from(Set.from(myContactIds).difference(Set.from(blockedUserId)));

                            return StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('users')
                                  .where('id', whereIn: finalList.isEmpty ?   [''] : finalList).snapshots(),
                                  // .where('id', whereIn: myContactIds.isEmpty ?   [''] : myContactIds).snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final List<ChatUser> chatUsersList = snapshot.data!.docs.map((e) => ChatUser.fromJson(e.data()),)
                                      .where((element) => element.name!.toLowerCase().contains(searchController.text.toLowerCase()),)
                                      .toList()..sort((a, b) => a.name!.compareTo(b.name!),);
                                  return ListView.builder(
                                      itemCount: chatUsersList.length,
                                      itemBuilder: (context, index) {
                                        return ContactCardScreen(
                                          chatUser: chatUsersList[index],
                                        );
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
                      );
                    }else{
                      return Container();
                    }
                  },
                )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(

        onPressed: () {
          TextEditingController editingControllerEmail = TextEditingController();
          showBottomSheetAddNewContact(context, editingControllerEmail, "Add Contact");
        },
        child: const Icon(Iconsax.message_add),
      ),
    );
  }
}
