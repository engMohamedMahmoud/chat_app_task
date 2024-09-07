import 'package:elarousi_task/firebase/firebase_db.dart';
import 'package:elarousi_task/model/chat_user.dart';
import 'package:elarousi_task/provider/provider_app.dart';
import 'package:elarousi_task/widgets/components.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import 'widgets/bottom_sheet_picker_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool enabledName = false;
  bool enableAbout = false;
  bool enableEmail = false;
  ChatUser? me;

  @override
  void initState() {
    me = Provider.of<ProviderApp>(context, listen: false).me;

    // TODO: implement initState
    super.initState();
    nameController.text = me!.name!;
    aboutController.text = me!.about!;
    emailController.text = me!.email!;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderApp>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child:  Column(
                children: [
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        provider.me!.image == ""
                            ? const CircleAvatar(
                                radius: 70,
                              )
                            : CircleAvatar(
                                radius: 70,
                                backgroundImage: NetworkImage(provider.me!.image!),
                              ),
                        Positioned(
                          right: -10,
                          bottom: -10,
                          child: IconButton.filled(
                              onPressed: () {
                                // ImagePicker imagePicker = ImagePicker();
                                displayBottomSheet(context);
                              },
                              icon: const Icon(Iconsax.edit)),
                        )
                      ],
                    ),
                  ),
                  heightSpace,

                  /// name section
                  Card(
                    child: ListTile(
                      leading: const Icon(Iconsax.user_octagon),
                      trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              enabledName = !enabledName;
                            });
                          },
                          icon: const Icon(Iconsax.edit)),
                      title: TextField(
                        controller: nameController,
                        enabled: enabledName,
                        decoration: const InputDecoration(
                            labelText: "Name", border: InputBorder.none),
                      ),
                    ),
                  ),

                  /// about
                  Card(
                    child: ListTile(
                      leading: const Icon(Iconsax.information),
                      trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              enableAbout = !enableAbout;
                            });
                          },
                          icon: const Icon(Iconsax.edit)),
                      title: TextField(
                        controller: aboutController,
                        enabled: enableAbout,
                        decoration: const InputDecoration(
                            labelText: "About", border: InputBorder.none),
                      ),
                    ),
                  ),

                  /// email section
                  Card(
                    child: ListTile(
                      leading: const Icon(Iconsax.user_octagon),
                      trailing: IconButton(
                          onPressed: () {
                          },
                          icon: const Icon(Iconsax.edit)),
                      title: TextField(
                        controller: emailController,
                        enabled: enableEmail,
                        decoration: const InputDecoration(
                            labelText: "Email", border: InputBorder.none),
                      ),
                    ),
                  ),



                  heightSpace,
                  ElevatedButton(
                      onPressed: () {
                        FireDb().editProfile(aboutController.text, nameController.text).then((v){
                         setState(() {
                           enableAbout = false;
                           enabledName = false;
                           provider.getUserDetails();
                         });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer),
                      child: Center(child: Text("Save".toUpperCase())))
                ],
              )


        ),
      ),
    );
  }
}
