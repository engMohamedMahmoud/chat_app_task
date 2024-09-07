import 'dart:io';

import 'package:elarousi_task/provider/provider_app.dart';
import 'package:elarousi_task/screens/home/shared_message_data/widget/groups/send_btn_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:share_handler/share_handler.dart';
import '../../../../../firebase/firebase_db.dart';
import '../../../../../firebase/firebase_storage.dart';
import '../../../../../model/group_chat_model.dart';
import '../../../../../operations/single_funcs.dart';

class GroupsSentList extends StatelessWidget {
  final GroupChatModel groupChatModel;
  final String sharedData;
  final SharedMedia media;
  final int index;

  const GroupsSentList(
      {super.key,
      required this.groupChatModel,
      required this.sharedData,
      required this.media,
      required this.index});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderApp>(context);
    return Card(
      child: ListTile(
          leading: CircleAvatar(
            child: Text(groupChatModel.name![0].toUpperCase()),
          ),
          title: Text(groupChatModel.name ?? "Group Name"),
          subtitle: Text(
            groupChatModel.lastMessage == ""
                ? "Send First Message"
                : groupChatModel.lastMessage!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Consumer<ProviderApp>(
            builder: (context, loadingProvider, child) {
              bool isLoading = loadingProvider.loadingIndex == index;
              return isLoading
                  ? const CircularProgressIndicator()
                  : IconButton(
                  onPressed:() async {provider.setLoadingIndex(index);

                  if (sharedData.isNotEmpty) {
                    FireDb().sendGroupMessage(sharedData, groupChatModel.id!, groupChatModel, 'text').then((value) => provider.resetLoadingIndex(),);
                  } else {
                    for (int i = 0; i < media.attachments!.length; i++) {
                      if (media.attachments![i]?.type == SharedAttachmentType.image) {
                        FireStorage().sendGroupMessageFile(file: File(media.attachments![i]!.path), groupId: groupChatModel.id!, groupChatModel: groupChatModel,
                        ).then((value) => provider.resetLoadingIndex(),);
                      }
                    }
                    
                  }
                  PaintingBinding.instance.imageCache.clear();
                  await DefaultCacheManager().emptyCache();

                  },
                  icon: const Icon(Icons.send));
            },
          )),
    );
  }
}
