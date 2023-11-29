import 'dart:io';
import 'package:bibleartwallpaperhd/screens/splash.dart';
import 'package:bibleartwallpaperhd/services/admobService.dart';
import 'package:bibleartwallpaperhd/services/notification.dart';
import 'package:bibleartwallpaperhd/utils/notificationSelected.dart';
import 'package:bibleartwallpaperhd/utils/sliderModel.dart';
import 'package:bibleartwallpaperhd/widgets/showLoadingWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  SharedPreferences? prefs;
  bool? showOnboarding;
  BuildContext? mContext;

  Future<void> _initOnBoarding(BuildContext context) async {
    AdmobService.checkIfUserIsSubscribed();
    mContext = context;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    prefs = await SharedPreferences.getInstance();
    showOnboarding = prefs!.getBool("showOnboarding") ?? true;
  }

  Future notificationSelected(String payLoad) async {
    NotificationSelected(mContext!, true);
  }

  @override
  void initState() {
    tz.initializeTimeZones();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _initOnBoarding(context),
        builder: (context, result) {
          if (result.connectionState != ConnectionState.done) {
            return ShowLoadingWidget();
          }

          if (showOnboarding == false) {
            return Splash();
          }

          return Sliders();
        });
  }
}

class Sliders extends StatefulWidget {
  @override
  _SlidersState createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  List<SliderModel> mySlides =[];
  int slideIndex = 0;
  late PageController controller;

  Widget _buildPageIndicator(bool isCurrentPage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      height: isCurrentPage ? 10.0 : 6.0,
      width: isCurrentPage ? 10.0 : 6.0,
      decoration: BoxDecoration(
        color: isCurrentPage ? Colors.grey : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    mySlides = getSlides();
    controller = new PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xff3C8CE7), const Color(0xff00EAFF)])),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: MediaQuery.of(context).size.height - 100,
          child: PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                slideIndex = index;
              });
            },
            children: <Widget>[
              SlideTile(
                imagePath: mySlides[0].getImageAssetPath(),
                title: mySlides[0].getTitle(),
                desc: mySlides[0].getDesc(),
              ),
              SlideTile(
                imagePath: mySlides[1].getImageAssetPath(),
                title: mySlides[1].getTitle(),
                desc: mySlides[1].getDesc(),
              ),
              SlideTile(
                imagePath: mySlides[2].getImageAssetPath(),
                title: mySlides[2].getTitle(),
                desc: mySlides[2].getDesc(),
              ),
              SlideTile(
                imagePath: mySlides[3].getImageAssetPath(),
                title: mySlides[3].getTitle(),
                desc: mySlides[3].getDesc(),
              ),
              SlideTile(
                imagePath: mySlides[4].getImageAssetPath(),
                title: mySlides[4].getTitle(),
                desc: mySlides[4].getDesc(),
              ),
            ],
          ),
        ),
        bottomSheet: slideIndex != 4
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        controller.animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.linear);
                      },
                      child: Text(
                        "SKIP",
                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          for (int i = 0; i < 5; i++) i == slideIndex ? _buildPageIndicator(true) : _buildPageIndicator(false),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: InkWell(
                        onTap: () {
                          controller.animateToPage(slideIndex + 1, duration: Duration(milliseconds: 500), curve: Curves.linear);
                        },
                        splashColor: Colors.blue[50],
                        child: Text(
                          "NEXT",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : InkWell(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool("showOnboarding", false);
                  Navigator.of(context).pushReplacementNamed('splash');
                },
                child: Container(
                  height: Platform.isIOS ? 70 : 60,
                  color: Theme.of(context).primaryColor,
                  alignment: Alignment.center,
                  child: Text(
                    "GET STARTED NOW",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
      ),
    );
  }
}

class SlideTile extends StatelessWidget {
  final String? imagePath, title, desc;

  SlideTile({this.imagePath, this.title, this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 200,
            height: 200,
            child: Image.asset(imagePath!),
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            title!,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30, color: Theme.of(context).primaryColor),
          ),
          SizedBox(
            height: 20,
          ),
          Text(desc!,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14))
        ],
      ),
    );
  }
}
