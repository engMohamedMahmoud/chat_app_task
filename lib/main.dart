import 'package:elarousi_task/firebase/notifications/push_notification.dart';
import 'package:elarousi_task/provider/provider_app.dart';
import 'package:elarousi_task/screens/auth/login_screen.dart';
import 'package:elarousi_task/screens/setup_profile/setup_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase/notifications/local_notifications_service.dart';
import 'firebase_options.dart';
import 'provider/member_provider.dart';
import 'screens/home/app_layout/app_layout.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Future.wait([
    PushNotificationsService.init(),//2
    LocalNotificationService.init(),//3
  ]);
  // PushNotificationsService.init();
  // LocalNotificationService.init();



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => ProviderApp()),
      ],
      // create: (context) => ProviderApp(),
      child: Consumer<ProviderApp>(
        builder: (context, value, child) => MaterialApp(
          title: 'Tactical',
          themeMode: value.themeMode,
          darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Color(value.mainColor), brightness: Brightness.dark)),
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor:  Color(value.mainColor),
                  brightness: Brightness.light),
              useMaterial3: true),
          debugShowCheckedModeBanner: false,
          home: StreamBuilder(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (FirebaseAuth.instance.currentUser!.displayName == "" ||
                    FirebaseAuth.instance.currentUser!.displayName == null) {
                  return const SetupProfile();
                } else {
                  return  const AppLayoutScreen(currentIndex:0,);
                }
              } else {
                return const LoginScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
