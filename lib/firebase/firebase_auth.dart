import 'dart:async';
import 'package:elarousi_task/model/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireAuth {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore db = FirebaseFirestore.instance;
  static User user = auth.currentUser!;

  /// create new in database
  static Future createUser() async {
    ChatUser chatUser = ChatUser(
        id: FirebaseAuth.instance.currentUser!.uid,
        name: FirebaseAuth.instance.currentUser!.displayName ?? "",
        email: FirebaseAuth.instance.currentUser!.email ?? "",
        about: 'Hello, ${FirebaseAuth.instance.currentUser!.uid}',
        image: '',
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        lastActivated: DateTime.now().millisecondsSinceEpoch.toString(),
        pushToken: '',
        online: false,
        myUsers: []);

    // create collection in db
    await db
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(chatUser.toJson())
        .then((b) {
      print("user id is ${chatUser.id}");
      print("user email is ${chatUser.email}");
    });
  }

  Future updateOnline(bool online) async {
    await db
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'online': online,
      'last_activated': DateTime.now().millisecondsSinceEpoch.toString()
    });
  }

  Future getToken(String token) async {
    await db
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"push_token": token});
  }


}
