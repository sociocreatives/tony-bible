import 'package:bibleartwallpaperhd/services/notification.dart';
import 'package:bibleartwallpaperhd/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(seconds: 5), () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (!prefs.containsKey('showWeeklyReminder')) {
          await prefs.setBool('showWeeklyReminder', true);
          await NotificationService().scheduledNotification();
        }
        if (!prefs.containsKey('playSlideshowMusic'))await prefs.setBool('playSlideshowMusic', true);
        if (!prefs.containsKey('shuffleSlideshowMusic'))await prefs.setBool('shuffleSlideshowMusic', true);
        if (!prefs.containsKey('showSlideshowInfoDialog'))await prefs.setBool('showSlideshowInfoDialog', true);
        if(mounted)Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
                child: Text(
              Constants.appName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
          ),
          Positioned(
            bottom: 50,
            right: 0,
            left: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Powered by Horizon Publishing"),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
