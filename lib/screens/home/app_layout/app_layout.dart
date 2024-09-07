import 'dart:async';

import 'package:elarousi_task/firebase/firebase_auth.dart';
import 'package:elarousi_task/provider/provider_app.dart';
import 'package:elarousi_task/screens/home/shared_message_data/shared_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_handler/share_handler.dart';
import '../../../utils/colors.dart';
import 'package:provider/provider.dart';

class AppLayoutScreen extends StatefulWidget {
  final int currentIndex;
  const AppLayoutScreen({super.key, required this.currentIndex});

  @override
  State<AppLayoutScreen> createState() => _AppLayoutScreenState(currentIndex);
}

class _AppLayoutScreenState extends State<AppLayoutScreen> {
  int currentIndex;
  StreamSubscription<SharedMedia>? _streamSubscription;
  SharedMedia? media;

  PageController pageController = PageController();

  _AppLayoutScreenState(this.currentIndex);

  @override
  void initState() {
    Provider.of<ProviderApp>(context, listen: false).getValueSharedPreferences();
    Provider.of<ProviderApp>(context, listen: false).getUserDetails();

    SystemChannels.lifecycle.setMessageHandler((message)  {
      if (message.toString() == 'AppLifecycleState.resumed') {
         FireAuth().updateOnline(true);
      } else if (message.toString() == 'AppLifecycleState.paused' || message.toString() == 'AppLifecycleState.inactive') {
         FireAuth().updateOnline(false);
      }
      return Future.value(message);
    });

    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }


  Future<void> initPlatformState() async {
    final handler = ShareHandlerPlatform.instance;
    media = await handler.getInitialSharedMedia();

    // Listen to media shared to the app when the app is closed or in the background
    ShareHandlerPlatform.instance.getInitialSharedMedia().then((SharedMedia? value) {
      if (!mounted) return;
      setState(() {
        media = value;
        if(value?.content != null || value?.attachments != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SharedDataFileScreen(
                    sharedData: media?.content ?? "",
                    media: value!,
                  )));
        }

      });
    },);

    _streamSubscription = handler.sharedMediaStream.listen((SharedMedia media) {
      if (!mounted) return;
      setState((){
        this.media = media;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SharedDataFileScreen(
                  sharedData: this.media?.content ?? "",
                  media: media,
                )));
      });
    });





  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 1,
        selectedIndex: currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            currentIndex = value;
            pageController.jumpToPage(value);
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Iconsax.message), label: "Chat"),
          NavigationDestination(icon: Icon(Iconsax.messages), label: "Group"),
          NavigationDestination(icon: Icon(Iconsax.user), label: "Contacts"),
          NavigationDestination(icon: Icon(Iconsax.setting), label: "Settings"),
        ],
      ),
    );
  }
}
