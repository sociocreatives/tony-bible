import 'dart:ffi';
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

class FavouritesTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  FavouritesTab(this.scaffoldKey);

  @override
  _FavouritesTabState createState() => _FavouritesTabState();
}

class _FavouritesTabState extends State<FavouritesTab> {
  late String userUid;
  List<Widget> cardsList = [];
  Map<String,Map<String,dynamic>> imagesUrl = {};
  late AdmobInterstitial interstitialAd;

  @override
  void initState() {
    super.initState();
    if(AdmobService.isUserSubscribed == false){
      interstitialAd = AdmobService.getInterstitialAd()!;
      interstitialAd.load();
    }
  }

  Future<bool> _getUserFavs(BuildContext context)async{
    cardsList.clear();
    ShowProgressDialog showProgressDialog = ShowProgressDialog(context);
    userUid = await FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference favRef = FirebaseDatabase.instance.ref().child('users').child(userUid).child('favourites');
    DataSnapshot snapshot0 =  await favRef.get();
    Map<String, dynamic> values0 =
        Map<String, dynamic>.from(snapshot0.value as Map<String, dynamic>);
    List<dynamic> keys0 = values0.keys.toList();

    if(keys0.length==0){ return false;}

    for(var key0 in keys0){
      List<dynamic> keys1 = values0[key0].keys.toList();
      for(var key1 in keys1){
        DataSnapshot snapshot1 =  await favRef.child(key0).child(key1).get();
        Map<String, dynamic> values =
            Map<String, dynamic>.from(snapshot1.value as Map<String, dynamic>);

        Map<String,dynamic> map = {
          'url':values['url'],
          'book': values['book'],
          'chapter': values['chapter'],
          'fromVerse': values['fromVerse'],
          'toVerse': values['toVerse'],
        };
        imagesUrl.addAll({values['title']: map});

        cardsList.add(
            StatefulBuilder(
                builder: (context, cState) {
                  String subCategory = key0;
                  bool _likeState = true;

                  Future<void> share(String url) async {
                    await FlutterShare.share(
                        title: Constants.appName,
                        text: 'Wallpaper Share',
                        linkUrl: url,
                        chooserTitle: values['title']
                    );
                  }

                  return InkWell(
                    onTap: ()async{
                      List<String> wallpaperList = [];
                      wallpaperList.addAll(<String>["",""]);
                      wallpaperList.add(key1);
                      wallpaperList.add(values['title']);
                      Map<String,dynamic> map = {
                        "wallpaperList": wallpaperList,
                        "wallpaperMap": values,
                      };
                      wallpaperList.add(key1);
                      // if (interstitialAd != null && await interstitialAd.isLoaded) {
                      //   interstitialAd.show();
                      // }
                      Navigator.of(context).pushNamed('wallpaperView',arguments: map);
                    },
                    child: Card(
                      elevation: 8,
                      child: Container(
                        height: 150,
                        child: Row(
                          children: [
                            Container(
                              width:120,
                              child: CachedNetworkImage(
                                imageUrl: values['url'],
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
                                        values['title'],
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
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
                                            onTap: ()async{
                                              await showProgressDialog.show();
                                              if(_likeState == true){
                                                _likeState = false;
                                                await FirebaseDatabase.instance.ref().child('users').child(userUid).child('favourites')
                                                    .child(subCategory).child(key1).remove();
                                              }else{
                                                _likeState = true;
                                                await FirebaseDatabase.instance.ref().child('users').child(userUid).child('favourites')
                                                    .child(subCategory).child(key1).set(values);
                                              }
                                              await showProgressDialog.hide();
                                              setState(()=>null);
                                            },
                                            child: Column(
                                              children: [
                                                _likeState == true ? Icon(Icons.favorite,color: Colors.red,) : Icon(Icons.favorite_border_outlined),
                                                Text("Like"),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: (){
                                              share(values['url']);
                                            },
                                            child: Column(
                                              children: [
                                                Icon(Icons.share_outlined),
                                                Text("Share"),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: ()async{
                                              final status = await Permission.storage.request();
                                              if(status.isGranted){
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  new SnackBar(
                                                    content: new Text("Download Started!",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                                var response = await Dio().get(
                                                    values['url'],
                                                    options: Options(responseType: ResponseType.bytes));
                                                final extDirectory = await ImageGallerySaver.saveImage(
                                                    Uint8List.fromList(response.data),
                                                    quality: 100,
                                                    name: values['title']
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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: MaterialButton(
                                              onPressed: ()async {
                                                await showProgressDialog.show();
                                                await NotificationSelected(context,false).setWallpaperFromFile(
                                                    imageName:  values['title'],
                                                    url: values['url'],
                                                    scaffoldKey: widget.scaffoldKey, context: context
                                                );
                                                await showProgressDialog.hide();
                                              },
                                              child: Text("Set As Wallpaper"),
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
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
                }
            )
        );
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<bool>(
      future: _getUserFavs(context),
      builder: (context, snapshot) {
        if(snapshot.connectionState != ConnectionState.done){
          return ShowLoadingWidget();
        }

        if(snapshot.data == null){
          return Container(
            child: Center(
              child: Text("No Favourites selected!"),
            ),
          );
        }

        return Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: BlinkingButton(()async{
                        // if (interstitialAd != null && await interstitialAd.isLoaded) {
                        //   interstitialAd.show();
                        // }
                        Navigator.of(context).pushNamed('slideShow',arguments: imagesUrl);
                      }
                      ),
                    ),
                  ],
                ),
            ),
            Expanded(
              child: ListView(
                children: cardsList,
              ),
            ),
          ],
        );
      }
    );
  }
}
