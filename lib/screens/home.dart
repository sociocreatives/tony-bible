import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:bibleartwallpaperhd/homeTabs/favouritesTab.dart';
import 'package:bibleartwallpaperhd/homeTabs/homeTab.dart';
import 'package:bibleartwallpaperhd/homeTabs/settingsTab.dart';
import 'package:bibleartwallpaperhd/services/admobService.dart';
import 'package:bibleartwallpaperhd/services/notification.dart';
import 'package:bibleartwallpaperhd/utils/constants.dart';
import 'package:bibleartwallpaperhd/widgets/showLoadingWidget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  int _currentTab = 0;

  Future<void> initPlugin(context) async {
    try {
      final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
      // if (status == TrackingStatus.notDetermined) {
      //   showCustomTrackingDialog(context);
      // }
    } catch (e) {
      print("AppTrackingTransparency Error: " + e.toString());
    }
  }

  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 1, // Show rate popup on first day of install.
    minLaunches: 5, // Show rate popup after 5 launches of app after minDays is passed.
  );

  _showAppInfoDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("App Info"),
            content: FutureBuilder<DataSnapshot>(
                future: FirebaseDatabase.instance.ref().child('App Description').child('description').get(),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container(height: 300, child: ShowLoadingWidget());
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 300,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(snapshot.data!.value as String),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 20,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Close"),
                      ),
                    ],
                  );
                }),
          );
        });
  }

  @override
  void initState() {
    Provider.of<NotificationService>(context,listen: false).initialize();
    super.initState();
    if (Platform.isIOS) {
      SchedulerBinding.instance.addPostFrameCallback((_) => initPlugin(context));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rateMyApp.init();
      if (mounted && rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(context);
      }
    });
  }

  void _launchPrivacyUrl() async {
    var url =  Uri.parse('https://bible-art-wallpaper-hd.web.app/privacy-policy.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchTermsUrl() async {
    var url = Uri.parse('https://bible-art-wallpaper-hd.web.app/terms-conditions.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [HomeTab(), FavouritesTab(scaffoldState), SettingsTab(scaffoldState)];

    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          Constants.appName,
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (choice) {
              if (choice == Constants.AppInfo) {
                _showAppInfoDialog(context);
              } else if (choice == Constants.RateMe) {
                rateMyApp.showRateDialog(context);
              } else if (choice == Constants.ContactMe) {
                Navigator.of(context).pushNamed('contactMe');
              } else if (choice == Constants.privacy) {
                _launchPrivacyUrl();
              } else if (choice == Constants.terms) {
                _launchTermsUrl();
              }
            },
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        backgroundColor: Theme.of(context).primaryColor,
        selectedFontSize: 16,
        showSelectedLabels: true,
        selectedItemColor: Colors.white,
        onTap: (value) {
          setState(() {
            _currentTab = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: tabs[_currentTab]),
          AdmobService.admobBannerWidget(),
        ],
      ),
    );
  }
}
