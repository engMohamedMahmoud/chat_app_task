import 'dart:async';
import 'dart:convert';
import 'package:elarousi_task/model/chat_room.dart';
import 'package:elarousi_task/model/group_chat_model.dart';
import 'package:elarousi_task/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import '../model/chat_user.dart';
import '../model/report_model.dart';

class FireDb {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  /// check if email is found or not
  Future createChatRoom(String email) async {

    QuerySnapshot userEmail = await db.collection('users').where('email', isEqualTo: email).get();

    QuerySnapshot blockedUserEmail = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('blockUsers').get();
    final blockedUserIds = blockedUserEmail.docs.map((e) => e.id,).toList();


    /// check that email is exist or not
    if (userEmail.docs.isNotEmpty && !blockedUserIds.contains(userEmail.docs.first.id)) {
      /// sort members list
      List<String> members = [
        FirebaseAuth.instance.currentUser!.uid,
        userEmail.docs.first.id
      ]..sort((a, b) => a.compareTo(b));

      ChatRoom chatRoom = ChatRoom(
          id: members.toString(),
          members: members,
          lastMessage: "",
          lastMessageTime: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(), isBlocked: false);

      /// check if room is exist or not
      QuerySnapshot existRoom = await db
          .collection('chatRoom')
          .where('members', isEqualTo: members)
          .get();

      // create collection in db
      if (existRoom.docs.isEmpty) {
        await db
            .collection('chatRoom')
            .doc(members.toString())
            .set(chatRoom.toJson());
      }
    }
  }

  Future createGroupRoom(String groupName, List<String> members) async {
    String groupId = const Uuid().v1();
    members.add(FirebaseAuth.instance.currentUser!.uid);
    GroupChatModel groupChatModel = GroupChatModel(
        id: groupId,
        name: groupName,
        image: '',
        members: members,
        admin: [FirebaseAuth.instance.currentUser!.uid],
        lastMessage: '',
        lastMessageTime: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now().millisecondsSinceEpoch.toString());
    await db.collection('groups').doc(groupId).set(groupChatModel.toJson());
  }

  Future addNewContact(BuildContext context, String email) async {

    QuerySnapshot userEmail = await db.collection('users').where('email', isEqualTo: email).get();

    QuerySnapshot blockedUserEmail = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('blockUsers').get();
    final blockedUserIds = blockedUserEmail.docs.map((e) => e.id,).toList();

    if (userEmail.docs.isNotEmpty && !blockedUserIds.contains(userEmail.docs.first.id)) {
      String userId = userEmail.docs.first.id;
      await db
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'my_users': FieldValue.arrayUnion([userId])
      }).then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$email user became new friend'))),);
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$email user is blocked')));
    }
  }

  /// send message
  Future sendMessage(
      String toId, String message, String roomId, ChatUser chatUser,
      {String? typeMessageData}) async {
    String messageId = const Uuid().v1();
    MessageModel messageModel = MessageModel(
        id: messageId,
        toId: toId,
        fromId: FirebaseAuth.instance.currentUser!.uid,
        msg: message,
        type: typeMessageData == 'text'
            ? 'text'
            : typeMessageData == 'image'
                ? 'image'
                : 'voice',
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        read: '');
    print(
        "messageModel.type ${typeMessageData == 'text' ? 'text' : typeMessageData == 'image' ? 'image' : 'voice'}");

    await db
        .collection('chatRoom').doc(roomId).collection('messages').doc(messageId).set(messageModel.toJson()).then((value) =>
          sendNotifications(chatUser: chatUser, msg: typeMessageData == 'text' ? message : typeMessageData == 'image' ? 'image' : 'voice',),);

    /// read last image
    await db.collection('chatRoom').doc(roomId).update({
      'last_message': typeMessageData == 'voice'
          ? 'voice'
          : typeMessageData == 'image'
              ? 'image'
              : message,
      'last_message_time': DateTime.now().millisecondsSinceEpoch.toString()
    });
  }

  /// send group message
  Future sendGroupMessage(String msg, String groupId,
      GroupChatModel groupChatModel, String type) async {
    List<ChatUser> chatUsers = [];
    groupChatModel.members = groupChatModel.members!
        .where(
          (element) => element != FirebaseAuth.instance.currentUser!.uid,
        )
        .toList();
    db
        .collection('users')
        .where('id', whereIn: groupChatModel.members)
        .get()
        .then(
          (value) => chatUsers.addAll(value.docs.map(
            (e) => ChatUser.fromJson(e.data()),
          )),
        );
    String messageId = const Uuid().v1();
    MessageModel messageModel = MessageModel(
        id: messageId,
        toId: '',
        fromId: FirebaseAuth.instance.currentUser!.uid,
        msg: msg,
        type: type == 'text'
            ? msg
            : type == 'image'
                ? 'image'
                : 'voice',
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        read: '');

    await db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .set(messageModel.toJson())
        .then(
      (value) {
        for (var element in chatUsers) {
          sendNotifications(
              chatUser: element,
              msg: type == 'text'
                  ? msg
                  : type == 'image'
                      ? 'image'
                      : 'voice',
              groupName: groupChatModel.name!);
        }
      },
    );

    /// read last image
    await db.collection('groups').doc(groupId).update({
      'last_message': type == 'text'
          ? msg
          : type == 'image'
              ? 'image'
              : 'voice',
      'last_message_time': DateTime.now().millisecondsSinceEpoch.toString()
    });
  }

  Future readMessage(String roomId, String messageId) async {
    await db
        .collection('chatRoom')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  Future updateMessage(String roomId, String messageId, String updateMsg,
      MessageModel lastMessageModel) async {
    await db
        .collection('chatRoom')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({'msg': updateMsg});

    ////// update last image

    if (messageId == lastMessageModel.id) {
      await db.collection('chatRoom').doc(roomId).update({
        'last_message': updateMsg,
      });
    }
  }

  Future deleteMessage(
      String roomId, List<String> msgs, ChatUser chatUser) async {
    if (msgs.length == 1) {
      await db
          .collection('chatRoom')
          .doc(roomId)
          .collection('messages')
          .doc(msgs.first)
          .delete()
          .then((value) async {
        await db.collection('chatRoom').doc(roomId).update({
          'last_message': chatUser.about,
          'last_message_time': DateTime.now().millisecondsSinceEpoch.toString()
        });
      });
    } else {
      for (var element in msgs) {
        await db
            .collection('chatRoom')
            .doc(roomId)
            .collection('messages')
            .doc(element)
            .delete();
      }
    }
  }

  //update message

  Future editGroup(String groupId, String name, List members) async {
    await db
        .collection('groups')
        .doc(groupId)
        .update({'name': name, "members": FieldValue.arrayUnion(members)});
  }

  Future editMessageGroup(String groupId, String messageId, String updateMsg,
      MessageModel lastMessageModel) async {
    await db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .update({'msg': updateMsg});

    if (messageId == lastMessageModel.id!) {
      /// update last message
      await db.collection('groups').doc(groupId).update({
        'last_message': updateMsg,
        'last_message_time': DateTime.now().millisecondsSinceEpoch.toString()
      });
    }
  }

  Future removeMemberOfGroupChat(
    String groupId,
    String memberId,
  ) async {
    await db.collection('groups').doc(groupId).update({
      "members": FieldValue.arrayRemove([memberId])
    });
  }

  Future promptAdminOfGroupChat(
    String groupId,
    String adminId,
  ) async {
    await db.collection('groups').doc(groupId).update({
      "admin": FieldValue.arrayUnion([adminId])
    });
  }

  Future removeAdminOfGroupChat(
    String groupId,
    String adminId,
  ) async {
    await db.collection('groups').doc(groupId).update({
      "admin": FieldValue.arrayRemove([adminId])
    });
  }

  Future editProfile(
    String about,
    String name,
  ) async {
    await db
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'name': name, "about": about});
  }

  /// get access token for notification from project settings => Service accounts
  Future<String> getAccessToken() async {


    final serviceAccountJson ={
      "type": "service_account",
      "project_id": "coursechat-462e3",
      "private_key_id": "e48c1e9112a49abc7a3819e98d2733e3ba82b96e",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCkzDb86EqnczgI\nxB2+ILeeDD2LpzQpFVZk9SmdPvtsnJmuS/KvsHtB3CclBkyu3Gjrdn9P359csCFo\n8A1gIBTRKwe/iUQ2dmr97e7XLFVlGPz66by+Wdg2A94T6Q3DsNjGkqzyRbRfx6wQ\nkIUG0pkenCzHRnDrQ9uM3MTERrfyxBPcAI2bB8PhPnBk+NcGY10h1DSfW1voLBxg\nlZaz984mPRNdRMkRXMmA+Cp4dBmFq9uPadEoX4Sj4UiLDPFJ1fRIa0pZVaE/yim7\nPWERcUf5x33pSw7CmvJHRRp47SBnv7hHFCaM9v3IwhogaF+YsSA6hODiCkRQK1FL\nkEb3KA75AgMBAAECggEABxZKykpcse7TWuBao+Tys8O0mEWy78FdjpUftDkTkiXG\nuVqSyUA+f/D6NGFpxgTvwV1YBEgkD++TJqW/YLVNSXsfdJRwPPD191pwI9jIPPZi\nJF6nVOUdCaJvWBpBrHso5DR5AFvdcfEIUuRw+n+8DgQkknCF33HZOamU3LJqq4n2\nNLt+h1GoChEiNbX6z8OmZAH6XxdEXm6gGRKvENnUtIE+Gw+lO0JzReQxJqRSlc4L\n8ldKAuigVfyNRwpP4cjHV2FMUiVcEYobVnAguG6QQ6IDIpgEdO4vsY5o+RGCvkKD\nxFLeRXZVObD7K8IXLva3WOSO48HsMj0aAAxP52zT8QKBgQDh7k2V43EfnA0MgZiA\nKfqPITtBeCHrFyasTHlzX/qM0DgdIgqrAC1ZvAjS58JlxtHJt3PDZsihsagYhysa\nSjysko2hus1GWbvZW3LNMNap9QcMAtxNtNLQxWOOewKDArDuby/yoMsqPhp/0zP0\n07L3+7RFjAFxv9rt/pKdMh7mkwKBgQC6uwrQg1NEO1lnVfPNcA9Noj6OV4sXyt0G\nKO4g07nmAGNVwjm6QHJZbhNl/Hfk9vb6C/x9K6jCFQWpedr2PFwQ+p8xkj6wc/3i\ndGd3RN/gdAN7SqR3pf5a77SOJYLwQQv9CFZ82TkrrrbbV7MGCEDx2sNmxTYY452u\nn3lYC4b/wwKBgGKtgpWE0VPNBKYBtGnF6/m3ufnOToIvimSWwjTyJqx6BQg0ZhRp\n72TSC8iSEQYC4H4J8jXWHqsAvTp5TwocgoOdPt70h9PCPZmhp3KXciqpKnrEhRQr\ndihZDjKc52vxMPXy+i4urI22sjxCMt8r128YMJRvofHcqfJozgB6c6ShAoGAEfKG\nUJI+v5Egv7DgNP+vSNvuPUomwUurQLtQX/FZrcSdx5FacQ9erj/JN4UzlNsz08ax\nJuq6VqUknSxsIjyc8LjV8jLHObh8T3a2txz0k6My7ne3JRTcRKtDZGIwmpz15QUX\nIvrR5uPtCVn9h/flHhnTrB4KXAwMjMshI5hACncCgYEAzNLPAJxt0f5gQs+fm6Bb\nOxrifZFn+PvF/cPZ+oPjcRc2LaRadr9fUd97nXO7GM6pSPphl5e6rXG5x3CvFjem\nsgfCliaQqoFGVMfchV8G5G1JJ6dppyEC8xJpG0LJNvAIbBP2TR4Mcdz1m+sKW3IH\nuKkFWW+1sV8XOeIazJzRyQs=\n-----END PRIVATE KEY-----\n",
      "client_email": "fcmchatappfirst@coursechat-462e3.iam.gserviceaccount.com",
      "client_id": "117963168093547658811",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/fcmchatappfirst%40coursechat-462e3.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };


    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    try {
      http.Client client = await auth.clientViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

      auth.AccessCredentials credentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
              auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
              scopes,
              client);

      client.close();
      print(
          "Access Token: ${credentials.accessToken.data}"); // Print Access Token
      return credentials.accessToken.data;
    } catch (e) {
      print("Error getting access token: $e");
      return "";
    }
  }

  Future sendNotifications({required ChatUser chatUser, required String msg, String? groupName}) async {
    final String serverTokenKey = await getAccessToken();

    const String urlEndPoint = "https://fcm.googleapis.com/v1/projects/coursechat-462e3/messages:send";

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverTokenKey'
    };

    final Map<String, dynamic> bodyMessage = {
      'message': {
        'token': chatUser.pushToken!,
        'notification': {'title': groupName ?? chatUser.name!, 'body': msg},
      }
    };

    print(bodyMessage);

    final http.Response response = await http.post(Uri.parse(urlEndPoint),
        headers: headers, body: jsonEncode(bodyMessage));

    print(response.statusCode);
    print(response.body);
  }

  /// Report user
  Future reportUser(String messageId, String userId) async {
    String reportId = const Uuid().v1();
    ReportModel reportModel = ReportModel(
        id: reportId,
        reportedBy: FirebaseAuth.instance.currentUser!.uid,
        messageId: messageId,
        userId: userId,
        createdAt: DateTime.now().millisecondsSinceEpoch.toString());

    await db
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('reports')
        .doc(reportId)
        .set(reportModel.toJson());
  }

  /// Block user
  Future blockUser(String userId) async {
    await db
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('blockUsers')
        .doc(userId)
        .set({});

    QuerySnapshot userChatRoom = await db.collection('chatRoom').where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid).get();
    Set userChatRoomList1 = userChatRoom.docs.map((e) => e.id,).toSet();
    QuerySnapshot otherUserChatRoom = await db.collection('chatRoom').where('members', arrayContains: userId).get();
    Set userChatRoomList2 = otherUserChatRoom.docs.map((e) => e.id,).toSet();

    await db.collection('chatRoom').doc(userChatRoomList1.intersection(userChatRoomList2).first).update({
      'is_blocked': true,
    });
    
    
  }

  Future unBlockUser(String blockedUserId) async {
    await db
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('blockUsers')
        .doc(blockedUserId)
        .delete();

    QuerySnapshot userChatRoom = await db.collection('chatRoom').where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid).get();
    Set userChatRoomList1 = userChatRoom.docs.map((e) => e.id,).toSet();
    QuerySnapshot otherUserChatRoom = await db.collection('chatRoom').where('members', arrayContains: blockedUserId).get();
    Set userChatRoomList2 = otherUserChatRoom.docs.map((e) => e.id,).toSet();

    await db.collection('chatRoom').doc(userChatRoomList1.intersection(userChatRoomList2).first).update({
      'is_blocked': false,
    });

  }

  /// Get blocked users stream

  Stream<List<ChatUser>> getBlockedUsersList(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('blockUsers')
        .snapshots()
        .asyncMap(
      (event) async {
        // get blocked users list ids
        final blockedUserIds = event.docs
            .map(
              (e) => e.id,
            )
            .toList();

        final userDocs = await Future.wait(blockedUserIds.map(
          (blockId) =>
              FirebaseFirestore.instance.collection('users').doc(blockId).get(),
        ));

        return userDocs
            .map(
              (e) => ChatUser.fromJson(e.data()!),
            )
            .toList();
      },
    );
  }

  Stream<List<ChatRoom>> getChatRoomsStreamBlockedUsersList() {
    return FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('blockUsers').snapshots().asyncMap((snapshot) async {
        // get blocked users list
        final blockedUserIds = snapshot.docs.map((e) => e.id,).toList();
        // get all user chat rooms
        final allCurrentUserRooms =  await FirebaseFirestore.instance.collection('chatRoom').
        where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid).get();

        List<ChatRoom> allRooms = allCurrentUserRooms.docs.map((e) => ChatRoom.fromJson(e.data()),).toList();
        List<ChatRoom> myRooms =  allRooms.where((room) =>
        !blockedUserIds.contains(room.members!.where((element) => element != FirebaseAuth.instance.currentUser!.uid,).toList().first),).toList();

        return myRooms;
      },
    );
  }
}
