import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:bibleartwallpaperhd/services/admobService.dart';
import 'package:bibleartwallpaperhd/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SlideShow extends StatefulWidget {
  final Map<String,Map<String,dynamic>> imgMap;
  SlideShow(this.imgMap);

  @override
  _SlideShowState createState() => _SlideShowState();
}

class _SlideShowState extends State<SlideShow> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late SharedPreferences sharedPreferences;
  late int slideShowDuration;
  List<List<dynamic>> _selectedMusic = [];
  int index = 0;

  Future<void> _initSlideshow(BuildContext context) async{
    try{
      List<String> _savedSelectedMusic = [];
      _selectedMusic.clear();

      sharedPreferences = await SharedPreferences.getInstance();
      slideShowDuration = sharedPreferences.getInt('slideShowDuration') ?? Constants.defaultSlideShowDuration;

      bool playMusic = sharedPreferences.getBool('playSlideshowMusic') ?? true;
      if(!playMusic)return;

      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/music/';
      if(await Directory(filePath).exists()){
        List<FileSystemEntity> fileList = Directory("$filePath").listSync();
        for(FileSystemEntity file in fileList){
          Uint8List list = await  File(file.path).readAsBytes();
          _selectedMusic.add(['local',list,file.path]);
        }
      }

      bool playAll = false;
      if(sharedPreferences.containsKey("selectedMusic")){
        _savedSelectedMusic = sharedPreferences.getStringList('selectedMusic')!;
      }else{
        playAll = true;
      }
      final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
      List<String> musicList = jsonDecode(manifestJson).keys.where((String key) => key.startsWith('assets/music/')).toList();
      for(String musicPath in musicList){
        if (musicPath.contains(".mp3")) {
          String musicTitle = musicPath.replaceAll('assets/music/', "").replaceAll('_', " ").replaceAll('.mp3', "");
          String path = musicPath.replaceAll('assets/', "");
          if (_savedSelectedMusic.contains(musicTitle) || playAll) {
            ByteData bytes = await rootBundle.load(musicPath);
            Uint8List list = await bytes.buffer.asUint8List();
            _selectedMusic.add(['asset', list, path]);
          }
        }
      }

      if(sharedPreferences.containsKey("shuffleSlideshowMusic")){
        bool? isShuffle =
            await sharedPreferences.getBool('shuffleSlideshowMusic');
        if (isShuffle!) _selectedMusic.shuffle();
      }
      if(_selectedMusic.length>0)_playMusic();

      bool showMusicInfoDialog = await sharedPreferences.getBool('showSlideshowInfoDialog') ?? true;
      if(showMusicInfoDialog)_showMusicDialog(context);
    }catch(e,s){
      print(e);
      print(s);
    }
  }

  _playMusic()async{
    if(index > _selectedMusic.length-1) index = 0;
    if(Platform.isIOS){
      if(_selectedMusic[index][0] == 'asset'){
        _audioPlayer.play(AssetSource("${(_selectedMusic[index][2])}"));
      }else{
        _audioPlayer.play(DeviceFileSource("${(_selectedMusic[index][2])}"));
      }
    }else{
      _audioPlayer.play(BytesSource(_selectedMusic[index][1])).catchError((onError)=>print(onError.toString()));
    }
  }

  _showMusicDialog(BuildContext context)async{
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Slideshow Music"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text("To Change the duration of the Slideshow, Music selection and other slideshow controls, navigate to the home screen of the app and click on the settings tab."),
                    )
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: ()async{
                        Navigator.pop(context);
                      },
                      child: Text("Close"),
                    ),
                    TextButton(
                      onPressed: ()async{
                        await sharedPreferences.setBool('showSlideshowInfoDialog',false);
                        Navigator.pop(context);
                      },
                      child: Text("Don't Show\nThis Again",style: TextStyle(color: Colors.red),),
                    ),
                  ],
                )
              ],
            ),
          );
        }
    );

  }

  @override
  void dispose() async{
    await _audioPlayer.stop();
    await _audioPlayer.release();
    await _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((event) async{
      await _audioPlayer.stop();
      await _audioPlayer.release();
      index++;
      _playMusic();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SLIDESHOW",style: TextStyle(color: Colors.white),),
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
          future: _initSlideshow(context),
          builder: (context, result) {
            if(result.connectionState != ConnectionState.done){
              return Center(
                child: SpinKitWave(
                  color: Colors.white,
                  size: 50.0,
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: CarouselSlider(
                    items: widget.imgMap.entries.map((entry)=> Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: entry.value['url'],
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width,
                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(value: downloadProgress.progress))),
                              errorWidget: (context, url, error) => Icon(Icons.error),
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
                                    entry.key,
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
                              onPressed: (){
                                Map<String,String> map = {
                                  'book':entry.value['book'],
                                  'chapter':entry.value['chapter'],
                                  'fromVerse':entry.value['fromVerse'],
                                  'toVerse':entry.value['toVerse'],
                                };
                                Navigator.of(context).pushNamed('bibleView',arguments: map);

                              },
                              child: Text(entry.value['book']+" Chapter: "+entry.value['chapter']+" From verse:"+entry.value['fromVerse']+" to "+entry.value['toVerse']),
                              color: Colors.white,
                              elevation: 8,
                            ),
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                    )).toList(),
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.8,
                      viewportFraction: 1.0,
                      enlargeCenterPage: true,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: slideShowDuration),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
                Container(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AdmobService.admobBannerWidget(),
                  ),
                )
              ],
            );
          }
      ),
    );
  }
}
