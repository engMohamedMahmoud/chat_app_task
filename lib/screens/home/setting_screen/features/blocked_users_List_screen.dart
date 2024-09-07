import 'package:elarousi_task/firebase/firebase_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'widgets/card_block_widget.dart';

class BlockedUsersListScreen extends StatefulWidget {
  const BlockedUsersListScreen({super.key});

  @override
  State<BlockedUsersListScreen> createState() => _BlockedUsersListScreenState();
}

class _BlockedUsersListScreenState extends State<BlockedUsersListScreen> {
  bool searched = false;
  TextEditingController searchController = TextEditingController();
  List myContactIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Blocked Users'),
        // ),
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
                      onChanged: (value) {
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
              : const Text("My Blocked Users"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder(
            stream: FireDb().getBlockedUsersList(FirebaseAuth.instance.currentUser!.uid),
            builder: (context, snapshot) {
              if(snapshot.hasError){
                return const Center(child: Text('Error...'),);
              }

              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator(),);
              }

              if (snapshot.hasData) {
                /// load complete

                final blockedUsers = snapshot.data!.where(
                      (element) =>
                      element.name!.toLowerCase().contains(searchController.text.toLowerCase()),
                )
                    .toList()..sort((a, b) => a.name!.compareTo(b.name!),);
                print("blockedUsers $blockedUsers");
                return blockedUsers.isNotEmpty
                    ? ListView.builder(
                        itemCount: blockedUsers.length,
                        itemBuilder: (context, index) {
                          final user = blockedUsers[index];
                          return CardBlockWidget(user: user);
                        },
                      )
                    : const Center(
                        child: Text("No blocked users"),
                      );
              } else {
                return Container();
              }
            },
          ),
        ));
  }
}
