import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../utils/colors.dart';

class CustomTextformfield extends StatefulWidget {
  final TextInputType textInputType;
  bool isPassword;
  final String labelName;
  final Widget widget;
  final TextEditingController editingController;

  CustomTextformfield(
      {super.key,
      required this.textInputType,
      required this.isPassword,
      required this.labelName,
      required this.widget,
      required this.editingController});

  @override
  State<CustomTextformfield> createState() => _CustomTextformfieldState();
}

class _CustomTextformfieldState extends State<CustomTextformfield> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: TextFormField(
        controller: widget.editingController,
        keyboardType: widget.textInputType,
        obscureText: widget.isPassword ? obscure : false,
        validator: (value)=> value == ""? "required" : null ,
        decoration: InputDecoration(
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                    icon: const Icon(Iconsax.eye))
                : const SizedBox(),
            contentPadding: const EdgeInsets.all(16),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kPrimaryColor)),
            label: Text(widget.labelName),
            prefixIcon: widget.widget,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
