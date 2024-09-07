import 'package:elarousi_task/firebase/firebase_db.dart';
import 'package:elarousi_task/model/message_model.dart';
import 'package:flutter/material.dart';

void showMessageUpdateDialog(BuildContext context, String roomId, String msgId, TextEditingController textEditingController, bool isGroup, MessageModel lastMessageModel) {

  showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        //title
        title:  Row(
          children: [
            const Icon(Icons.message,),
            Text(' Update Message',style: Theme.of(context).textTheme.bodyLarge,)
          ],
        ),

        //content
        content: TextFormField(
          //initialValue: updatedMsg,
          controller: textEditingController,
          maxLines: null,
          // onChanged: (value) => updatedMsg = value,
          decoration: const InputDecoration(
              hintText: "Message",
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)))),),
        //actions
        actions: [
          //cancel button
          MaterialButton(
              onPressed: () {
                //hide alert dialog
                Navigator.pop(context);
              },
              child:  Text('Cancel', style: Theme.of(context).textTheme.bodyLarge,)),

          //update button
          MaterialButton(
              onPressed: () {
                //hide alert dialog
                Navigator.pop(context);
                if(isGroup == false){
                  FireDb().updateMessage(roomId, msgId, textEditingController.text, lastMessageModel);
                }else{
                  FireDb().editMessageGroup(roomId, msgId, textEditingController.text, lastMessageModel);
                }

              },
              child:  Text('Update', style: Theme.of(context).textTheme.bodyLarge,))
        ],
      ));
}

