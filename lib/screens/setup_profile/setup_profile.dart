import 'package:elarousi_task/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/colors.dart';
import '../../widgets/components.dart';
import '../../widgets/custom_textformfield.dart';

class SetupProfile extends StatefulWidget {
  const SetupProfile({super.key});

  @override
  State<SetupProfile> createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  TextEditingController nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async => await FirebaseAuth.instance.signOut(),
              icon: const Icon(Iconsax.logout_1))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heightSpace,
                heightSpace,
                Text(
                  "Welcome",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  "Please, enter your name",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                CustomTextformfield(
                    editingController: nameController,
                    textInputType: TextInputType.text,
                    isPassword: false,
                    labelName: "User name",
                    widget: const Icon(Iconsax.user)),
                heightSpace,
                ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        FirebaseAuth.instance.currentUser!
                            .updateDisplayName(nameController.text)
                            .then((vale) => FireAuth.createUser());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.all(16)),
                    child: Center(
                        child: Text(
                      "Continue".toUpperCase(),
                      style: const TextStyle(color: Colors.black),
                    ))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
