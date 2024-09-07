import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../firebase/firebase_db.dart';

void showOptions(BuildContext context, String messageId, String userId, bool isGroupChat) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
          child: Wrap(
            children: [

              /// report message button
              ListTile(
                leading: const Icon(Iconsax.flag),
                title: const Text("Report"),
                onTap: () {
                  Navigator.pop(context);
                  reportMessage(context, messageId, userId);
                },
              ),

              /// block user button
              ListTile(
                leading: const Icon(Icons.block_sharp),
                title: const Text("Block"),
                onTap: () {

                  /// dismiss dialog
                  Navigator.pop(context);
                  blockedUser(context, userId);

                },
              ),

              /// cancel button
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text("Cancel"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ));
    },
  );
}

void reportMessage(BuildContext context, String messageId, String userId) {
  showDialog(
    context: context,
    builder: (context) =>
        AlertDialog(
          title: Text(
            "Report Message",
            style: Theme
                .of(context)
                .textTheme
                .titleSmall,
          ),
          content: Text(
            "Are you sure you want to report this message?",
            style: Theme
                .of(context)
                .textTheme
                .bodyLarge,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  FireDb().reportUser(messageId, userId);
                  Navigator.pop(context);
                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(const SnackBar(
                      content: Text("Message Reported")));
                      },
                child: const Text("Report")),
          ],
        ),
  );
}
void  blockedUser(BuildContext context, String userId) {
  showDialog(
    context: context,
    builder: (context) =>
        AlertDialog(
          title: Text("Block User", style: Theme.of(context).textTheme.titleSmall,),
          content: Text("Are you sure you want to block this user?", style: Theme.of(context).textTheme.bodyLarge,),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  FireDb().blockUser(userId);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(const SnackBar(
                      content: Text("User Blocked")));
                      },
                child: const Text("Block")),
          ],
        ),
  );
}
