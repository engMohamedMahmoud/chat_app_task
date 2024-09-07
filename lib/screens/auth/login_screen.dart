import 'package:elarousi_task/screens/auth/forget_password/forget_password_screen.dart';
import 'package:elarousi_task/utils/colors.dart';
import 'package:elarousi_task/widgets/custom_textformfield.dart';
import 'package:elarousi_task/widgets/logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../provider/provider_app.dart';
import '../../widgets/components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderApp>(context);

    TextEditingController editingControllerEmail = TextEditingController();
    TextEditingController editingControllerPassword = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return Scaffold(
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
                  "مرحبا بكم في ",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  "Educatly Task",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                CustomTextformfield(
                    editingController: editingControllerEmail,
                    textInputType: TextInputType.emailAddress,
                    isPassword: false,
                    labelName: "Email",
                    widget: const Icon(Iconsax.direct)),
                CustomTextformfield(
                    editingController: editingControllerPassword,
                    textInputType: TextInputType.text,
                    isPassword: true,
                    labelName: "Password",
                    widget: const Icon(Iconsax.password_check)),
                heightSpace,
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      child: const Text("Forget Password?"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgetPasswordScreen()));
                      },
                    )
                  ],
                ),
                heightSpace,
                ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: editingControllerEmail.text,
                              password: editingControllerPassword.text)
                          .then(
                        (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Login Successfully")));
                        },
                      ).onError(
                        (error, stackTrace) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Please, check email and password")));
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.all(16)),
                    child: provider.isLoading == false
                        ? Center(
                            child: Text(
                            "Login".toUpperCase(),
                            style: const TextStyle(color: Colors.black),
                          ))
                        : const Center(
                            child: CircularProgressIndicator(),
                          )),
                heightSpace,
                OutlinedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: editingControllerEmail.text,
                              password: editingControllerPassword.text)
                          .then((value) => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content:
                                      Text("Account Created Successfully"))))
                          .onError(
                            (error, stackTrace) => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text(
                                        "This email is already used"))),
                          );
                    },
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(16)),
                    child: Center(
                        child: Text(
                      "Create Account".toUpperCase(),
                    ))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
