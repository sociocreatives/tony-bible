import 'dart:io';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdmobService with ChangeNotifier {
  static final bool useLiveCredentials = true;
  static AdmobInterstitial? interstitialAd;
  static bool? isUserSubscribed;

  static checkIfUserIsSubscribed() async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    EntitlementInfos entitlementInfos = customerInfo.entitlements;
    Map<String, EntitlementInfo> activeEntitlement = entitlementInfos.active;
    if (activeEntitlement.isEmpty) {
      isUserSubscribed = false;
    } else {
      isUserSubscribed = true;
    }
  }

  static String? getAdmobAppId() {
    if (useLiveCredentials == true) {
      if (Platform.isIOS) {
        return "ca-app-pub-2295969720544909~8420694151";
      } else if (Platform.isAndroid) {
        return "ca-app-pub-2295969720544909~6760139185";
      }
    } else {
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544~1458002511';
      } else if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544~3347511713';
      }
    }
  }

  static Future<Widget> _initBannerAd() async {
    if (isUserSubscribed == false) {
      await Admob.requestTrackingAuthorization().catchError((onError) {
        print("Admob Error: =======> " + onError.toString());
      });
      return Container(
        margin: EdgeInsets.only(bottom: 10.0, top: 10.0),
        child: AdmobBanner(
          adUnitId: getBannerAdUnitId() ?? "",
          adSize: AdmobBannerSize.BANNER,
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  static Widget admobBannerWidget() {
    return FutureBuilder<Widget>(
      future: _initBannerAd(),
      builder: (context, result) {
        if (result.data == null) {
          return SpinKitWave(
            color: Theme.of(context).primaryColor,
            size: 50.0,
          );
        }
        return result.data!;
      },
    );
  }

  static AdmobInterstitial? getInterstitialAd() {
    if (isUserSubscribed == false) {
      interstitialAd = AdmobInterstitial(
        adUnitId: getInterstitialAdUnitId() ?? "",
        listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
          if (event == AdmobAdEvent.closed) interstitialAd!.load();
        },
      );
    }
    return interstitialAd;
  }

  static String? getBannerAdUnitId() {
    if (useLiveCredentials == true) {
      if (Platform.isIOS) {
        return "ca-app-pub-2295969720544909/4306366932";
      } else if (Platform.isAndroid) {
        return "ca-app-pub-2295969720544909/1978246483";
      }
    } else {
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      }
    }
    return null;
  }

  static String? getInterstitialAdUnitId() {
    if (useLiveCredentials == true) {
      if (Platform.isIOS) {
        return "ca-app-pub-2295969720544909/7176072853";
      } else if (Platform.isAndroid) {
        return "ca-app-pub-2295969720544909/4740496416";
      }
    } else {
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      } else if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      }
    }
    return null;
  }

  static Future<bool> isSubscriptionExpired(String expiryDate) async {
    int currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).millisecondsSinceEpoch;
    int expDate = (DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(expiryDate)).millisecondsSinceEpoch;
    if (currentDate > expDate) {
      return true;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('subscriptionExpiryDate', expDate);
      isUserSubscribed = true;
      return false;
    }
  }
}
