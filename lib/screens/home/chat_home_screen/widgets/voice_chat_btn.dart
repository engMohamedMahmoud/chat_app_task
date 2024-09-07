import 'package:elarousi_task/firebase/firebase_storage.dart';
import 'package:elarousi_task/model/group_chat_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../../model/chat_user.dart';
import '../../../../provider/provider_app.dart';


class VoiceChatBtn extends StatefulWidget {
  final ProviderApp provider;
  final AudioRecorder record;
  final String roomId;
  final ChatUser? chatUser;
  final GroupChatModel? groupChatModel;

  const VoiceChatBtn({super.key, required this.provider, required this.record,  required this.roomId,  this.chatUser, this.groupChatModel});

  @override
  State<VoiceChatBtn> createState() => _VoiceChatBtnState();
}

class _VoiceChatBtnState extends State<VoiceChatBtn> {



  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
        onPressed: () async {
          final location = await getApplicationDocumentsDirectory();
          if(widget.provider.isRecord == false){
            FireStorage().startRecord( widget.provider,widget.record,location );
          }else {
            if(widget.roomId == ''){
              FireStorage().stopChatGroupRecord(widget.groupChatModel!.id!, widget.provider, widget.groupChatModel!, widget.record);
            }else{
              FireStorage().stopRecord(widget.roomId, widget.provider, widget.chatUser!, widget.record).then((value) {
                setState(() {
                  if (location.existsSync()) {
                    location.deleteSync(recursive: true);
                  }
                });
              },);

            }
          }
        },
        icon: widget.provider.isRecord == false? const Icon(Iconsax.microphone5) : const Icon(Iconsax.stop_circle4));
  }

}
