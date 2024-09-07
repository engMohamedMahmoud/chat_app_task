import 'dart:io';

import 'package:elarousi_task/firebase/firebase_storage.dart';
import 'package:elarousi_task/model/group_chat_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../model/chat_user.dart';
import '../../../../provider/provider_app.dart';

class BottomGroupChatTextField extends StatelessWidget {
  final GroupChatModel groupChatModel;
  final TextEditingController textEditingController;
  final ProviderApp provider;

  const BottomGroupChatTextField({
    super.key,
    required this.textEditingController,
    required this.groupChatModel, required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TextField(
        maxLines: 5,
        minLines: 1,
        controller: textEditingController,
        decoration: InputDecoration(
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  ImagePicker picker = ImagePicker();
                  XFile? image = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 50);
                  if (image != null) {
                    provider.changeStatusLoader(true);
                    FireStorage().sendGroupMessageFile(
                        file: File(image.path),
                        groupId: groupChatModel.id!, groupChatModel: groupChatModel,).then((value)=>provider.changeStatusLoader(false));
                  }
                },
                icon: const Icon(Iconsax.emoji_happy),
              ),
              IconButton(
                onPressed: () async {
                  ImagePicker picker = ImagePicker();
                  XFile? image = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 50);
                  if (image != null) {
                    provider.changeStatusLoader(true);
                    FireStorage().sendGroupMessageFile(
                      file: File(image.path),
                      groupId: groupChatModel.id!,groupChatModel: groupChatModel).then((value)=>provider.changeStatusLoader(false));
                  }
                },
                icon: const Icon(Iconsax.camera),
              ),
            ],
          ),
          border: InputBorder.none,
          hintText: "Message",
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}
