import 'package:elarousi_task/screens/home/chat_home_screen/chat.dart';
import 'package:elarousi_task/screens/home/group_chat_sreen/group_chat.dart';
import 'package:elarousi_task/screens/home/setting_screen/settings.dart';
import 'package:flutter/material.dart';

import '../screens/home/contacts_screen/contacts.dart';

Color kPrimaryColor = const Color(0xff0DF5E3);
Color kGrayColor = const Color(0xff8D8D8D);

List<Widget> screens = [
  const ChatScreen(),
  const GroupChatScreen(),
  const ContactsScreen(),
  const SettingsScreen(),
];