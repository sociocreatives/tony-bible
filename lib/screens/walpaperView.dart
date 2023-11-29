import 'package:admob_flutter/admob_flutter.dart';
import 'package:bibleartwallpaperhd/services/admobService.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class WallpaperView extends StatefulWidget {
  final Map<String,dynamic> map;
  WallpaperView(this.map);

  @override
  _WallpaperViewState createState() => _WallpaperViewState();
}

class _WallpaperViewState extends State<WallpaperView> {
  late AdmobInterstitial interstitialAd;

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

    List<String> wallpaperList = widget.map['wallpaperList'];
    Map<dynamic,dynamic> wallpaperMap = widget.map['wallpaperMap'];

    return  Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text(wallpaperList[4],style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: CachedNetworkImage(
                      imageUrl: wallpaperMap['url'],
                      fit: BoxFit.fitWidth,
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(value: downloadProgress.progress))),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          wallpaperMap['title'],
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width *0.9,
                  child: MaterialButton(
                    onPressed: ()async{
                      Map<String,String> map = {
                        'book':wallpaperMap['book'],
                        'chapter':wallpaperMap['chapter'],
                        'fromVerse':wallpaperMap['fromVerse'],
                        'toVerse':wallpaperMap['toVerse'],
                      };
                      // if (interstitialAd != null && await interstitialAd.isLoaded) {
                      //   interstitialAd.show();
                      // }
                      Navigator.of(context).pushNamed('bibleView',arguments: map);

                    },
                    child: Text(wallpaperMap['book']+" Chapter: "+wallpaperMap['chapter']+" From verse:"+wallpaperMap['fromVerse']+" to "+wallpaperMap['toVerse']),
                    color: Colors.white,
                    elevation: 8,
                  ),
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),
          Container(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AdmobService.admobBannerWidget(),
            ),
          )
        ],
      ),
    );
  }
}
