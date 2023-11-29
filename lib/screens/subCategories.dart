import 'dart:async';
import 'dart:collection';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:bibleartwallpaperhd/services/admobService.dart';
import 'package:bibleartwallpaperhd/widgets/showLoadingWidget.dart';
import 'package:bibleartwallpaperhd/widgets/showProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubCategories extends StatefulWidget {
  final String mainCategoryName;
  SubCategories(this.mainCategoryName);
  
  @override
  _SubCategoriesState createState() => _SubCategoriesState();
}

class _SubCategoriesState extends State<SubCategories> {
  late AdmobInterstitial interstitialAd;

  _showRestoreErrorDialog(BuildContext context){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Subscription Error"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Text("No previous subscription found!")),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text("Close"),
                    )
                  ],
                )
              ],
            ),
          );
        }
    );
  }

  _showSubScribeDialog(BuildContext pageContext){
    ShowProgressDialog showProgressDialog = ShowProgressDialog(context);

    showDialog(
      context: pageContext,
      builder: (context){
        return AlertDialog(
          title: Text("Subscription"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text("Please subscribe to get access to all categories with over 700 Classical Old and New testament paintings, without any advertising."),
                  ),
                ],
              ),
              Divider(height: 10,),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text("If you had already purchased, click on the restore button below")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        onPressed: ()async{
                          Navigator.pop(context);
                          await showProgressDialog.show();
                          CustomerInfo purchaserInfo = await Purchases.restorePurchases();
                          if(purchaserInfo == null || purchaserInfo.activeSubscriptions.isEmpty){
                            await showProgressDialog.hide();
                            _showRestoreErrorDialog(pageContext);
                          }else{
                              if (await AdmobService.isSubscriptionExpired(
                                  purchaserInfo.latestExpirationDate!)) {
                              await showProgressDialog.hide();
                              _showRestoreErrorDialog(pageContext);
                            }
                          }
                          await showProgressDialog.hide();
                          setState(() {});
                        },
                        child: Text("Restore Purchase"),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text("Cancel",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                  ),
                  MaterialButton(
                    onPressed: ()async {
                      Navigator.pop(context);
                      bool hasSubscribed = await Navigator.of(context).pushNamed('subscriptionPage') as bool;
                      if(hasSubscribed != null && hasSubscribed == true){
                        setState(()=>print("hasSubscribed ======>> true"));
                      }
                    },
                    child: Text("Subscribe Now",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Future<DataSnapshot> initFirebaseData() async{
    return await FirebaseDatabase.instance.ref().child('Categories').child('Sub-Categories')
        .orderByChild("mainCategory").equalTo(widget.mainCategoryName).get();
  }

  @override
  void initState() {
    super.initState();
    if(AdmobService.isUserSubscribed == false){
      interstitialAd = AdmobService.getInterstitialAd()!;
      interstitialAd.load();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mainCategoryName!,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: initFirebaseData(),
        builder: (context, snapshot) {
          if(snapshot.data == null){
            return ShowLoadingWidget();
          }

          Map<String,dynamic> values = {};

            List<dynamic> allKeys = snapshot.data.value.keys.toList();
            Map<dynamic, dynamic> unsortedValues =
                snapshot.data.value as Map<String, dynamic>;

          allKeys.forEach((key) {
            if(unsortedValues[key]['status'] == true){
              values.addAll(<String,dynamic>{key: unsortedValues[key]});
            }
          });

          var sortedKeys = values.keys.toList(growable:false)..sort((k1, k2) => values[k1]['displayName'].compareTo(values[k2]['displayName']));
          LinkedHashMap allValues = new LinkedHashMap.fromIterable(sortedKeys, key: (k) => k, value: (k) => values[k]);
          List<dynamic> keys = allValues.keys.toList();

          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  itemCount: keys.length,
                  itemBuilder: (BuildContext context, int index) {
                    BoxDecoration bDeco;
                    bool isFreeTag = values[keys[index]]['isFree'];
                    bool mustSubscribe = true;
                    if(values[keys[index]]['isFree'] == false && AdmobService.isUserSubscribed == false){
                      bDeco =  BoxDecoration(color: Colors.grey,backgroundBlendMode: BlendMode.saturation,);
                    }else{
                      mustSubscribe = false;
                    }
                    return InkWell(
                      onTap: ()async{
                        if(mustSubscribe){
                          _showSubScribeDialog(context);
                        }else{
                          // if (interstitialAd != null && await interstitialAd.isLoaded) {
                          //   interstitialAd.show();
                          // }
                          List<String> list = [widget.mainCategoryName,keys[index],values[keys[index]]['displayName']];
                          Navigator.of(context).pushNamed('wallpapers',arguments: list);
                        }
                      },
                      child: Card(
                        elevation: 8,
                        child: Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              color: Colors.black,
                              foregroundDecoration: bDeco,
                              child: CachedNetworkImage(
                                imageUrl: values[keys[index]]['thumbnail'],
                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                    Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(value: downloadProgress.progress))),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                            isFreeTag ? Positioned(
                              top: 10,
                              left: 0,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.red,
                                child: Text("FREE",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                            ): Container(),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2.0),
                                color: const Color(0xFF000000).withOpacity(0.5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        values[keys[index]]['displayName'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              AdmobService.admobBannerWidget(),
            ],
          );
        }
      ),
    );
  }
}
