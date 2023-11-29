import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:bibleartwallpaperhd/services/admobService.dart';
import 'package:bibleartwallpaperhd/utils/constants.dart';
import 'package:bibleartwallpaperhd/utils/notificationSelected.dart';
import 'package:bibleartwallpaperhd/widgets/blinkingButton.dart';
import 'package:bibleartwallpaperhd/widgets/showLoadingWidget.dart';
import 'package:bibleartwallpaperhd/widgets/showProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class Wallpapers extends StatefulWidget {
  final List<String> categoryList;

  Wallpapers(this.categoryList);

  @override
  _WallpapersState createState() => _WallpapersState();
}

class _WallpapersState extends State<Wallpapers> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String? userUid;
  Stream<String>? progressString;
  String home = "Home Screen", lock = "Lock Screen", both = "Both Screen", system = "System";
  AdmobInterstitial? interstitialAd;

  Future<void> share(String url) async {
    await FlutterShare.share(title: Constants.appName, text: 'Wallpaper Share', linkUrl: url, chooserTitle: widget.categoryList[1]);
  }

  @override
  void initState() {
    super.initState();
    if(AdmobService.isUserSubscribed == false){
      interstitialAd = AdmobService.getInterstitialAd();
      interstitialAd!.load();
    }
  }

  Future<DataSnapshot> _initWallPapers() async {
    userUid = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseDatabase.instance.ref().child('wallpapers').child(widget.categoryList[0]).child(widget.categoryList[1]).get();
  }



  @override
  Widget build(BuildContext context) {
    ShowProgressDialog showProgressDialog = ShowProgressDialog(context);
    Map<String, Map<String, dynamic>> imagesUrl = {};

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.categoryList[2],
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          BlinkingButton(() async{
            // if (interstitialAd != null && await interstitialAd.isLoaded) {
            //   interstitialAd.show();
            // }
            Navigator.of(context).pushNamed('slideShow', arguments: imagesUrl);
          }),
        ],
      ),
      body: FutureBuilder<DataSnapshot>(
          future: _initWallPapers(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return ShowLoadingWidget();
            }

            Map<String, dynamic> mapx = Map<String, dynamic>.from(
                snapshot.data!.value as Map<String, dynamic>);
            ;
            List<dynamic> allKeys = mapx.keys.toList();
            Map<dynamic, dynamic> values =
                snapshot.data!.value as Map<String, dynamic>;

            Map<dynamic, dynamic> newValues = {};

            allKeys.forEach((key) {
              if (values[key]['status'] == true) {
                newValues.addAll({key: values[key]});
              }
            });

            var sortedKeys = newValues.keys.toList(growable: false)..sort((k1, k2) => newValues[k1]['title'].compareTo(newValues[k2]['title']));
            LinkedHashMap allValues = new LinkedHashMap.fromIterable(sortedKeys, key: (k) => k, value: (k) => newValues[k]);
            List<dynamic> keys = allValues.keys.toList();

            keys.forEach((key) {
              Map<String, dynamic> map = {
                'url': allValues[key]['url'],
                'book': allValues[key]['book'],
                'chapter': allValues[key]['chapter'],
                'fromVerse': allValues[key]['fromVerse'],
                'toVerse': allValues[key]['toVerse'],
              };
              imagesUrl.addAll({allValues[key]['title']: map});
            });

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: keys.length,
                    itemBuilder: (BuildContext context, int index) {
                      return StatefulBuilder(builder: (context, cState) {
                        return FutureBuilder<DataSnapshot>(
                            future: FirebaseDatabase.instance
                                .ref()
                                .child('users')
                                .child(userUid!)
                                .child('favourites')
                                .child(widget.categoryList[1])
                                .child(keys[index])
                                .get(),
                            builder: (context, favSnapshot) {
                              if (favSnapshot.connectionState != ConnectionState.done) {
                                return Container();
                              }

                              return InkWell(
                                onTap: () async{
                                  List<String> newWallpaperList = [];
                                  newWallpaperList.addAll(widget.categoryList);
                                  newWallpaperList.add(keys[index]);
                                  newWallpaperList.add(allValues[keys[index]]['title']);
                                  Map<String, dynamic> map = {
                                    "wallpaperList": newWallpaperList,
                                    "wallpaperMap": allValues[keys[index]],
                                  };
                                  // if (interstitialAd != null && await interstitialAd.isLoaded) {
                                  //   interstitialAd.show();
                                  // }
                                  Navigator.of(context).pushNamed('wallpaperView', arguments: map);
                                },
                                child: Card(
                                  elevation: 8,
                                  child: Container(
                                    height: 150,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 120,
                                          child: CachedNetworkImage(
                                            imageUrl: allValues[keys[index]]['url'],
                                            progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(value: downloadProgress.progress))),
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  child: Text(
                                                    allValues[keys[index]]['title'],
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                    overflow: TextOverflow.clip,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          await showProgressDialog.show();
                                                          if (favSnapshot.data!
                                                                  .value ==
                                                              null) {
                                                            await FirebaseDatabase
                                                                .instance
                                                                .ref()
                                                                .child('users')
                                                                .child(userUid!)
                                                                .child(
                                                                    'favourites')
                                                                .child(widget
                                                                        .categoryList[
                                                                    1])
                                                                .child(
                                                                    keys[index])
                                                                .set(allValues[
                                                                    keys[
                                                                        index]]);
                                                          } else {
                                                            await FirebaseDatabase
                                                                .instance
                                                                .ref()
                                                                .child('users')
                                                                .child(userUid!)
                                                                .child(
                                                                    'favourites')
                                                                .child(widget
                                                                        .categoryList[
                                                                    1])
                                                                .child(
                                                                    keys[index])
                                                                .remove();
                                                          }
                                                          await showProgressDialog.hide();
                                                          cState(() {});
                                                        },
                                                        child: Column(
                                                          children: [
                                                            favSnapshot.data!
                                                                        .value ==
                                                                    null
                                                                ? Icon(Icons.favorite_border_outlined)
                                                                : Icon(
                                                                    Icons.favorite,
                                                                    color: Colors.red,
                                                                  ),
                                                            Text("Like"),
                                                          ],
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: true,//Platform.isAndroid,
                                                        child: InkWell(
                                                          onTap: () {
                                                            share(allValues[keys[index]]['url']);
                                                          },
                                                          child: Column(
                                                            children: [
                                                              Icon(Icons.share_outlined),
                                                              Text("Share"),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () async {
                                                          final status = await Permission.storage.request();
                                                          if (status.isGranted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              new SnackBar(
                                                                content: new Text(
                                                                  "Download Started!",
                                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                ),
                                                                backgroundColor: Colors.green,
                                                              ),
                                                            );
                                                            var response = await Dio().get(
                                                                allValues[keys[index]]['url'],
                                                                options: Options(responseType: ResponseType.bytes));
                                                            final extDirectory = await ImageGallerySaver.saveImage(
                                                                Uint8List.fromList(response.data),
                                                                quality: 100,
                                                                name: allValues[keys[index]]['title']
                                                            );
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              new SnackBar(
                                                                content: new Text(
                                                                  "Download Complete!",
                                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                ),
                                                                backgroundColor: Colors.green,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Icon(Icons.save_alt),
                                                            Text("Save"),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Visibility(
                                                    visible: Platform.isAndroid,
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: MaterialButton(
                                                            onPressed: () async {
                                                              await showProgressDialog.show();
                                                              await NotificationSelected(context,false).setWallpaperFromFile(
                                                                imageName:  allValues[keys[index]]['title'],
                                                                url: allValues[keys[index]]['url'],
                                                                scaffoldKey: _scaffoldKey, context: context
                                                              );
                                                              await showProgressDialog.hide();
                                                            },
                                                            child: Text(
                                                              "Set As Wallpaper",
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                            color: Theme.of(context).primaryColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      });
                    },
                  ),
                ),
                AdmobService.admobBannerWidget(),
              ],
            );
          }),
    );
  }
}
