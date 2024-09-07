import 'dart:io';
import 'package:elarousi_task/model/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:record/record.dart';

import '../model/group_chat_model.dart';
import '../provider/provider_app.dart';
import 'firebase_db.dart';

class FireStorage {
  Future sendMessageFile(
      {required File file,
      required String roomId,
      required String chatUserId, required ChatUser chatUser}) async {
    /// get reference
    final ref = FirebaseStorage.instance.ref().child('images/$roomId/${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}');

    /// upload file
    await ref.putFile(file);


    /// get file url from firebase  after uploading it
    String imageUrl = await ref.getDownloadURL();
    print("imageUrl $imageUrl");

    /// send file as message for user
    FireDb().sendMessage(chatUserId, imageUrl, roomId, chatUser, typeMessageData: 'image');
  }
  Future sendGroupMessageFile({required File file, required String groupId, required  GroupChatModel groupChatModel}) async {
    // String groupId = '1341e630-53fa-11ef-a736-5f4ae55971ae';
    /// get reference
    final ref = FirebaseStorage.instance.ref().child('images/$groupId/${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}');

    /// upload file
    await ref.putFile(file);


    /// get file url from firebase after uploading it
    String imageUrl = await ref.getDownloadURL();
    print("imageUrl $imageUrl");

    /// send file as message for user
    FireDb().sendGroupMessage( imageUrl, groupId, groupChatModel, 'image');
  }


  Future updateProfileImage({required File file}) async {
    /// get reference
    final ref = FirebaseStorage.instance.ref().child(
        'images/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}');

    /// upload file
    await ref.putFile(file);

    /// get file url from firebase after uploading it
    String imageUrl = await ref.getDownloadURL();

    /// send file as message for user
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({"image": imageUrl});
  }

  startRecord(ProviderApp providerApp, AudioRecorder record, Directory location) async{
    // Check and request permission if needed
    if (await record.hasPermission()) {
      // Start recording to file

      providerApp.changeStatusRecord(true);
      await record.start(const RecordConfig(), path: '${location.path}/${DateTime.now().millisecondsSinceEpoch}.m4a');
    }
  }

  Future stopRecord(String roomId, ProviderApp providerApp, ChatUser chatUser, AudioRecorder record) async{
    // Stop recording...
    providerApp.changeStatusLoader(true);
    providerApp.changeStatusRecord(false);
    String? path = await record.stop();
    print('stop record => path: $path');
    final ref = FirebaseStorage.instance.ref().child('voices/$roomId/${DateTime.now().millisecondsSinceEpoch}.${path!.split('.').last}');
    /// upload file
    await ref.putFile(File(path));
    // As always, don't forget this one.
    String voiceUrl = await ref.getDownloadURL();
    //

    await record.cancel();

    /// send file as message for user
    FireDb().sendMessage(chatUser.id!, voiceUrl, roomId, chatUser,typeMessageData: 'voice').then((value) => providerApp.changeStatusLoader(false));
  }

  Future stopChatGroupRecord(String roomId, ProviderApp providerApp, GroupChatModel groupChatModel, AudioRecorder record) async{
    // Stop recording...
    providerApp.changeStatusLoader(true);
    providerApp.changeStatusRecord(false);
    String? path = await record.stop();
    print('stop record => path: $path');
    final ref = FirebaseStorage.instance.ref().child('voices/$roomId/${DateTime.now().millisecondsSinceEpoch}.${path!.split('.').last}');
    /// upload file
    await ref.putFile(File(path));
    // As always, don't forget this one.
    String voiceUrl = await ref.getDownloadURL();
    //

    await record.cancel();
    /// send file as message for user
    FireDb().sendGroupMessage(voiceUrl, roomId, groupChatModel, 'voice').then((value) => providerApp.changeStatusLoader(false));
  }


}
