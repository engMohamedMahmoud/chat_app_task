import 'package:elarousi_task/model/group_chat_model.dart';
import 'package:elarousi_task/operations/single_funcs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_handler/share_handler.dart';
import '../../../../../provider/provider_app.dart';

class SendBtnGroup extends StatelessWidget {
  final int index;
  final GroupChatModel groupChatModel;
  final String sharedData;
  final SharedMedia media;

  const SendBtnGroup(
      {super.key,
      required this.index,
      required this.groupChatModel,
      required this.sharedData,
      required this.media});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderApp>(context);
    return Consumer<ProviderApp>(
      builder: (context, loadingProvider, child) {
        bool isLoading = loadingProvider.loadingIndex == index;
        return isLoading
            ? const CircularProgressIndicator()
            : IconButton(
                onPressed: sendReceivedSharedDate(
                    provider, index, sharedData, groupChatModel, media),
                icon: const Icon(Icons.send));
      },
    );
  }
}
