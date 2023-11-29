import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:merge_images/merge_images.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

class NotificationSelected{
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  BuildContext? mCtx;

  NotificationSelected(BuildContext context,bool isForNotification){
    mCtx = context;
    if(isForNotification == true){
      User? user = FirebaseAuth.instance.currentUser;
      if(user == null){
        _showNotificationDialog();
      }else{
        _startNotification(context);
      }
    }
  }



  _startNotification(BuildContext context) async{
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('favourites')
        .get();
    if(snapshot.value == null){
     _showNotificationDialog();
     return;
    }

    Map<dynamic, dynamic> values = snapshot.value as Map;
    List<dynamic> keys = values.keys.toList();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int autoWallpaperIndex = sharedPreferences.getInt("autoWallpaperIndex") ?? 0;

    if(keys.length >0){
      List<Map<dynamic,dynamic>> wallpapers = [];
      String url;
      String imageName;

      for(var key in keys){
        Map<dynamic,dynamic> wallpaperValues = values[key];
        List<dynamic> wallpaperKeys = wallpaperValues.keys.toList();
        for(var wallpaperKey in wallpaperKeys){
          wallpapers.add(wallpaperValues[wallpaperKey]);
        }
      }

      try{
        url = wallpapers[autoWallpaperIndex]['url'];
        imageName = wallpapers[autoWallpaperIndex]['title'];
        await sharedPreferences.setInt("autoWallpaperIndex", autoWallpaperIndex + 1 );
      }catch(e){
        print("autoWallpaperIndex ==========>> End reached");
        url = wallpapers[0]['url'];
        imageName = wallpapers[0]['title'];
        await sharedPreferences.setInt("autoWallpaperIndex", 0);
      }

      await setWallpaperFromFile(
        context: context,
          url: url,
          imageName: imageName,
          scaffoldKey: null
      );
    }
  }

  _showNotificationDialog(){
    showDialog(
        context: mCtx!,
        builder: (context){
          return AlertDialog(
            title: Text("No Favourites"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Select your favourite images to change your wall papers automatically."),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text("Cancel")
                    ),
                    TextButton(
                        onPressed: (){
                          Navigator.popAndPushNamed(context, "home");
                        },
                        child: Text("Select Now",style: TextStyle(color: Colors.green),)
                    ),
                  ],
                )
              ],
            ),
          );
        }
    );
  }

  Future<void> setWallpaperFromFile({
    required BuildContext context,
      required String url,
      String? imageName,
      GlobalKey<ScaffoldState>? scaffoldKey
  }) async {

    ui.Image blackImage = await ImagesMergeHelper.loadImageFromAsset('assets/blackImage1.png');
    File cachedFile = await DefaultCacheManager().getSingleFile(url);
    ui.Image image = await ImagesMergeHelper.loadImageFromFile(cachedFile);

    ui.Image mergedImage = await ImagesMergeHelper.margeImages([blackImage, image, blackImage], fit: false, direction: Axis.vertical, backgroundColor: Colors.black);

    var bytes = await mergedImage.toByteData(format: ui.ImageByteFormat.png);
    String tempPath = (await getTemporaryDirectory()).path;
    String fileName = 'wallpaper_${new Random().nextInt(1000)}.png';
    File newFile = File('$tempPath/$fileName');
    await newFile.writeAsBytes(
        bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));

    if (mergedImage != null) {
      var result = true;
      if (newFile.path != null) {
        try {
          int location = WallpaperManager.BOTH_SCREEN;
          result = await WallpaperManager.setWallpaperFromFile(
              newFile.path, location);
        } on PlatformException {
          result = false;
        }
        if(scaffoldKey != null){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              result ? "success" : "failed",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ));
        }
      } else {
        if(scaffoldKey != null){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Set Wallpaper canceled!",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }
}