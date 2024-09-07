
import 'package:elarousi_task/firebase/firebase_db.dart';
import 'package:flutter/material.dart';
import '../../../../../model/chat_user.dart';

void showUnBlockBox(BuildContext context, ChatUser user){
  showDialog(context: context, builder: (context) => AlertDialog(
    title: const Text('Unblock User'),
    content:  Text('Are you sure you want to unblock ${user.name}'),
    actions: [
      /// cancel button
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),

      /// unblock button
      TextButton(onPressed: () {
        /// perform block
        FireDb().unBlockUser(user.id!);
        /// dismiss dialog
        Navigator.pop(context);
        /// let user know of result
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Unblocked ${user.name!}")));
      }, child: const Text('Unblock')),

      
    ],
  ),);
}