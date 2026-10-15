import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'service/shared_pref_service.dart';
import 'service/notification_service.dart';
import 'route/app_binding.dart';
import 'route/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SharedPrefService.init();

  // Register FCM background handler BEFORE runApp (required for background/terminated state)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Push Notification Service
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        title: 'Track My Order',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splashScreen,
        getPages: AppBinding.pages,
        theme: ThemeData(useMaterial3: true),
        builder: (context, child) {
          ScreenUtil.ensureScreenSize();
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: FToastBuilder()(context, child),
          );
        },
      ),
    );
  }
}
