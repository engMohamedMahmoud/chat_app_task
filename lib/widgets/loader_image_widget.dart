import 'package:flutter/material.dart';
import '../utils/date_time.dart';

class LoaderImageWidget extends StatelessWidget {
  final bool isMessageFromMe;
  final String createdAt;
  const LoaderImageWidget({super.key, required this.isMessageFromMe, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),),
      child: Row(
        mainAxisAlignment: isMessageFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(top: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isMessageFromMe ? 16 : 0),
                  bottomRight: Radius.circular(isMessageFromMe ? 0 : 16),
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                )),
            color: isMessageFromMe ? Theme.of(context).colorScheme.background.withOpacity(0.2) : Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                height: 70, width: 70,
                constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width / 2),
                child:   Column(crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(child: CircularProgressIndicator(),),
                    SizedBox(width: isMessageFromMe ? 6 : 0,),
                    Text(MyDateTime.dateTimeFormat(createdAt).toLowerCase(), style: Theme.of(context).textTheme.labelSmall,),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
