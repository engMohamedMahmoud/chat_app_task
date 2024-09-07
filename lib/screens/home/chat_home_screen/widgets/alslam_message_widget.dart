
import 'package:elarousi_task/model/chat_user.dart';
import 'package:flutter/material.dart';

import '../../../../firebase/firebase_db.dart';
import '../../../../widgets/components.dart';

class AlslamMessageWidget extends StatelessWidget {
  final ChatUser chatUser;
  final String roomId;
  const AlslamMessageWidget({super.key, required this.chatUser, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => FireDb().sendMessage(
            chatUser.id!,
            "alslam 3lykm 👋",
            roomId,chatUser,
            typeMessageData: 'text'
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Text(
                  "👋",
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium,
                ),
                heightSpace,
                Text(
                  "alslam 3lykm ",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
