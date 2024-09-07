import 'dart:io';
import 'package:elarousi_task/screens/home/shared_message_data/widget/groups/listView_groups.dart';
import 'package:elarousi_task/screens/home/shared_message_data/widget/members/listview_members.dart';
import 'package:flutter/material.dart';
import 'package:share_handler/share_handler.dart';

//  source file : https://saileshdahal.com.np/sharing-media-from-external-to-flutter-app
class SharedDataFileScreen extends StatelessWidget {
  final String sharedData;
  final SharedMedia media;
  const SharedDataFileScreen({super.key, required this.sharedData, required this.media});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const  Text("Send to:"),),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:Row(
                    children: (media.attachments ?? []).map((attachment){
                      final path = attachment?.path;
                      if (path != null && attachment?.type == SharedAttachmentType.image) {
                        return
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(path),
                                fit: BoxFit.fill,
                                height: 150.0,
                                width: 150.0,
                              ),
                            ),
                          );
                      }else{
                        return Container();
                      }
          
                    }).toList(),
                  )
              ),
              const Text("Members"),
              ListviewMembers(sharedData: sharedData, media: media),
              const Text("Groups"),
              ListviewGroups(sharedData,media: media,),
          
            ],
          ),
        ),
      ),
    );
  }
}