import 'package:elarousi_task/firebase/firebase_auth.dart';
import 'package:elarousi_task/model/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderApp with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  int mainColor = 0xff4050B5;
  ChatUser? me;
  bool isLoading = false;
  bool isRecord = false;

  int _loadingIndex = -1;

  int get loadingIndex => _loadingIndex;


  changeStatusLoader(bool status) {
    isLoading = status;
    notifyListeners();
  }

  changeStatusRecord(bool status) {
    isRecord = status;
    notifyListeners();
  }

  changeMode(bool dark) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    sharedPreferences.setBool('dark', themeMode == ThemeMode.dark);
    notifyListeners();
  }

  changeColor(int c) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    mainColor = c;
    sharedPreferences.setInt('color', mainColor);
    notifyListeners();
  }

  getValueSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isDark = sharedPreferences.getBool('dark') ?? false;
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    mainColor = sharedPreferences.getInt('color') ?? 0xff4050B5;
    notifyListeners();
  }

  getUserDetails() async {
    String myId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .get()
        .then((value) async {
      me = ChatUser.fromJson(value.data()!);

      // creat instance of fbm
      FirebaseMessaging.instance.getToken().then((token) {
        if (token != null) {
          print("token device $token");
          me!.pushToken = token;
          FireAuth().getToken(token);
          // handleBackground();

        }
      });
      notifyListeners();
    });
    notifyListeners();
  }

  // Set the loading button's index and notify listeners
  void setLoadingIndex(int index) {
    _loadingIndex = index;
    notifyListeners();
  }

  // Reset the loading index to -1 (meaning no button is loading)
  void resetLoadingIndex() {
    _loadingIndex = -1;
    notifyListeners();
  }


}
