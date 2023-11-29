import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:bibleartwallpaperhd/routes/routes.dart';
import 'package:bibleartwallpaperhd/services/admobService.dart';
import 'package:bibleartwallpaperhd/services/notification.dart';
import 'package:bibleartwallpaperhd/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize();
  Admob.initialize();
  await Purchases.setDebugLogsEnabled(false);
  await Purchases.configure(Platform.isAndroid ? PurchasesConfiguration(Constants.androidKey) :  PurchasesConfiguration(Constants.appleKey));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Colors.grey;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: primaryColor,
      statusBarBrightness: Brightness.light, // Dark == white status bar -- for IOS.
      systemNavigationBarColor: primaryColor,
    ));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return  MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdmobService()),
        ChangeNotifierProvider(create: (_) => NotificationService())
      ],
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: primaryColor,
          appBarTheme: AppBarTheme(
              backgroundColor: primaryColor,
            iconTheme: IconThemeData(
                color: Colors.white
            )
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: 'onBoarding',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}

