import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/colors.dart';
import '../../../widgets/components.dart';
import '../../../widgets/custom_textformfield.dart';
import '../../../widgets/logo.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    TextEditingController editingControllerEmail = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Logo(),
                heightSpace,
                Text(
                  "Reset Password",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  "Please, enter your email",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                CustomTextformfield(
                    editingController: editingControllerEmail,
                    textInputType: TextInputType.emailAddress,
                    isPassword: false,
                    labelName: "Email",
                    widget: const Icon(Iconsax.direct)),

                heightSpace,
                ElevatedButton(
                    onPressed: () async {
                      if(formKey.currentState!.validate()){
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: editingControllerEmail.text).then((value){
                          Navigator.pop(context);
                          return ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                              showCloseIcon: true,
                              content: Text("Please, check your email")));
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.all(16)),
                    child: Center(
                        child: Text(
                          "Send Email".toUpperCase(),
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
