import 'package:bibleartwallpaperhd/screens/bibleView.dart';
import 'package:bibleartwallpaperhd/screens/contactMe.dart';
import 'package:bibleartwallpaperhd/screens/home.dart';
import 'package:bibleartwallpaperhd/screens/onBoarding.dart';
import 'package:bibleartwallpaperhd/screens/selectMusic.dart';
import 'package:bibleartwallpaperhd/screens/subscriptionPage.dart';
import 'package:bibleartwallpaperhd/screens/slideShow.dart';
import 'package:bibleartwallpaperhd/screens/splash.dart';
import 'package:bibleartwallpaperhd/screens/subCategories.dart';
import 'package:bibleartwallpaperhd/screens/wallpapers.dart';
import 'package:bibleartwallpaperhd/screens/walpaperView.dart';
import 'package:flutter/material.dart';

class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
     dynamic args = routeSettings.arguments;

    switch (routeSettings.name) {
      case 'onBoarding':
        return MaterialPageRoute(builder: (_) => OnBoarding());
      case 'splash':
        return MaterialPageRoute(builder: (_) => Splash());
      case 'home':
        return MaterialPageRoute(builder: (_) => Home());
      case 'subCategories':
        return MaterialPageRoute(builder: (_) => SubCategories(args));
      case 'wallpapers':
        return MaterialPageRoute(builder: (_) => Wallpapers(args));
      case 'wallpaperView':
        return MaterialPageRoute(builder: (_) => WallpaperView(args));
      case 'bibleView':
        return MaterialPageRoute(builder: (_) => BibleView(args));
      case 'contactMe':
        return MaterialPageRoute(builder: (_) => ContactMe());
      case 'slideShow':
        return MaterialPageRoute(builder: (_) => SlideShow(args));
      case 'subscriptionPage':
        return MaterialPageRoute(builder: (_) => SubscriptionPage());
      case 'selectMusic':
        return MaterialPageRoute(
            builder: (_) => SelectMusic(
                  key: null!,
                ));
      default:
        return errorRoute();
    }
  }

  static Route<dynamic> errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        body: Container(
          child: Center(
            child: Text(
              "Login Route Error!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    });
  }
}
