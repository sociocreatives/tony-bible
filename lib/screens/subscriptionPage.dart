import 'dart:async';
import 'dart:io';
import 'package:bibleartwallpaperhd/services/admobService.dart';
import 'package:bibleartwallpaperhd/widgets/showLoadingWidget.dart';
import 'package:bibleartwallpaperhd/widgets/showProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  late Offerings _offerings;

  Future<void> initPlatformState() async {
    _offerings = await Purchases.getOfferings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Subscriptions",
        style: TextStyle(color: Colors.white),
      )),
      body: FutureBuilder<void>(
        future: initPlatformState(),
        builder: (context, value) {
          if (value.connectionState != ConnectionState.done) {
            return ShowLoadingWidget();
          }
          return Column(
            children: [
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18.0),
                height: 200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Below are the subscriptions available indicating their length and price. Please select your preferred subscription package. Note that all subscriptions DO NOT have a free trial or introductory pricing.',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Platform.isAndroid
                        ? Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "All Subscriptions are are auto-newing and can be canceled at any time though the Google Play store app, under subscriptions",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          )
                        : Expanded(
                            child: Text(
                              "All Subscriptions are are auto-newing and can be canceled at any time.",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ],
                ),
              ),
              Expanded(
                  child: UpSellScreen(
                offerings: _offerings,
                key: null!,
              )), 
            ],
          );
        },
      ),
    );
  }
}

class UpSellScreen extends StatelessWidget {
  final Offerings offerings;

  UpSellScreen({required Key key, required this.offerings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (offerings == null) {
      return Center(
        child: Text(
          "No Products Found!",
          style: TextStyle(color: Colors.red),
        ),
      );
    } else {
      List<Package> package = offerings.all['Default']!.availablePackages;
      return ListView.builder(
        itemCount: package.length,
        itemBuilder: (context,index){
          return PurchaseButton(
            package: package[index],
            key: null!,
          );
        },
      );
    }
  }
}

class PurchaseButton extends StatelessWidget {
  final Package package;

  PurchaseButton({required Key key, required this.package}) : super(key: key);

  void Function; _initPurchase(ShowProgressDialog showProgressDialog, Package package, BuildContext context) async {
    await showProgressDialog.show();
    try {
      await Purchases.collectDeviceIdentifiers();
      CustomerInfo purchaserInfo = await Purchases.purchasePackage(package);
      String activeSubscription = purchaserInfo.activeSubscriptions.first;
      await showProgressDialog.hide();
      if (activeSubscription != null) {
        AdmobService.isUserSubscribed = true;
        Navigator.pop(context, true);
      }
    } catch (e) {
      await showProgressDialog.hide();
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        print("User cancelled");
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        print("User not allowed to purchase");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ShowProgressDialog showProgressDialog = ShowProgressDialog(context);
    return TextButton(
      onPressed: () async =>await _initPurchase(showProgressDialog, package, context),
      child: Card(
        elevation: 8,
        color: Colors.white,
        margin: EdgeInsets.only(left: 8,right: 8,bottom: 8,top: 20),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      package.storeProduct.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    package.storeProduct.priceString,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Text(
                        package.storeProduct.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(),
                      )),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
