
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../firebase/firebase_storage.dart';
import '../../../../../provider/provider_app.dart';

Future displayBottomSheet(BuildContext context, ) async{
  final provider = Provider.of<ProviderApp>(context,listen: false);
  return showModalBottomSheet(
      context: context,
      // backgroundColor: AppColor.secondaryTextColor.withOpacity(0.3),
      barrierColor: Colors.black87.withOpacity(0.5),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context){
        return StatefulBuilder(builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.image),
                title:  const Text('gallery'),
                onTap: () async {
                  ImagePicker imagePicker = ImagePicker();
                  XFile? image = await imagePicker.pickImage(source: ImageSource.gallery,imageQuality: 50);
                  if(image != null){
                    setState(() => Navigator.pop(context),);
                    FireStorage().updateProfileImage(file: File(image.path)).then((value){

                      provider.getUserDetails();
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title:  const Text('camera',),
                onTap: () async {
                  ImagePicker imagePicker = ImagePicker();
                  XFile? image = await imagePicker.pickImage(source: ImageSource.camera,imageQuality: 50);
                  if(image != null){
                    setState(() => Navigator.pop(context),);
                    FireStorage().updateProfileImage(file: File(image.path)).then((value){
                      // setState(() => Navigator.pop(context),);
                      provider.getUserDetails();
                    });
                  }
                },
              ),
            ],
          );
        },);
      });
}