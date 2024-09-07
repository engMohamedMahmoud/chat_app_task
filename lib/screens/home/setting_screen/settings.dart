import 'package:elarousi_task/firebase/firebase_db.dart';
import 'package:elarousi_task/provider/provider_app.dart';
import 'package:elarousi_task/screens/home/setting_screen/features/blocked_users_List_screen.dart';

import 'package:elarousi_task/screens/home/setting_screen/features/profile_screen.dart';
import 'package:elarousi_task/screens/home/setting_screen/features/qrCode_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../firebase/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderApp>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                minVerticalPadding: 40,
                leading: provider.me?.image == ""
                    ? const CircleAvatar(
                        radius: 30,
                      )
                    : CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(provider.me!.image!),
                      ),
                title: Text(provider.me!.name!),
                trailing: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QrcodeScreen()));
                    },
                    icon: const Icon(Iconsax.scan_barcode)),
              ),
              Card(
                child: ListTile(
                  title: const Text("Profile"),
                  leading: const Icon(Iconsax.user),
                  trailing: const Icon(Iconsax.arrow_right_3),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen())),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Blocked Users"),
                  leading: const Icon(Icons.block_rounded),
                  trailing: const Icon(Iconsax.arrow_right_3),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BlockedUsersListScreen())),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Theme"),
                  leading: const Icon(Iconsax.color_swatch),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            actions: [
                              ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Done"))
                            ],
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor: Colors.red,
                                onColorChanged: (value) {
                                  provider.changeColor(value.value);
                                },
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Dark Mode"),
                  leading: const Icon(Iconsax.user),
                  trailing: Switch(
                      value: provider.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        provider.changeMode(value);
                      }),
                ),
              ),
              Card(
                child: ListTile(
                  onTap: () async {
                    await FireAuth().updateOnline(false).then((value) async {
                      await FirebaseAuth.instance.signOut();
                    });
                  },
                  title: const Text("Logout"),
                  trailing: const Icon(Iconsax.logout_1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
