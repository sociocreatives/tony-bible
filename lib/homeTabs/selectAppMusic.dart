import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:bibleartwallpaperhd/widgets/showLoadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectAppMusic extends StatefulWidget {
  const SelectAppMusic({Key? key}) : super(key: key);

  @override
  _SelectAppMusicState createState() => _SelectAppMusicState();
}

class _SelectAppMusicState extends State<SelectAppMusic> {
  AudioPlayer _audioPlayer = AudioPlayer();
  List<List<dynamic>> _musicList = [];
  List<String> _savedSelectedMusic = [];
  late SharedPreferences sharedPreferences;

  Future<void> _getAllMusic(BuildContext context) async {
    sharedPreferences = await SharedPreferences.getInstance();
    _musicList.clear();

    bool selectAll = false;
    if (sharedPreferences.containsKey("selectedMusic")) {
      _savedSelectedMusic = sharedPreferences.getStringList('selectedMusic')!;
    } else {
      selectAll = true;
    }
    final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    List<String> musicList = jsonDecode(manifestJson).keys.where((String key) => key.startsWith('assets/music/')).toList();
    for (String musicPath in musicList) {
      if (musicPath.contains(".mp3")) {
        String musicTitle = musicPath.replaceAll('assets/music/', "").replaceAll('_', " ").replaceAll('.mp3', "");
        _musicList.add([
          musicTitle,
          selectAll
              ? true
              : _savedSelectedMusic.contains(musicTitle)
                  ? true
                  : false,
          musicPath
        ]);
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    await _audioPlayer.stop();
    await _audioPlayer.release();
    await _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () async {
                  List<String> list = [];
                  for (var music in _musicList) {
                    list.add(music[0]);
                  }
                  await sharedPreferences.setStringList('selectedMusic', list);
                  setState(() {});
                },
                child: Text(
                  "Select All",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              TextButton(
                onPressed: () async {
                  List<String> list = [];
                  for (var music in _musicList) {
                    list.remove(music[0]);
                  }
                  await sharedPreferences.setStringList('selectedMusic', list);
                  setState(() {});
                },
                child: Text(
                  "Remove All",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Select the music to play during slideshow",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
              child: FutureBuilder<void>(
                  future: _getAllMusic(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) return ShowLoadingWidget();
                    return ListView.builder(
                      itemCount: _musicList.length,
                      itemBuilder: (context, index) {
                        bool isPlaying = false;
                        return StatefulBuilder(builder: (context, state) {
                          return ListTile(
                            leading: Checkbox(
                              value: _musicList[index][1],
                              onChanged: (val) async {
                                if (val!) {
                                  _savedSelectedMusic.add(_musicList[index][0]);
                                  await sharedPreferences.setStringList('selectedMusic', _savedSelectedMusic);
                                  state(() {
                                    _musicList[index][1] = true;
                                  });
                                } else {
                                  _savedSelectedMusic.remove(_musicList[index][0]);
                                  await sharedPreferences.setStringList('selectedMusic', _savedSelectedMusic);
                                  state(() {
                                    _musicList[index][1] = false;
                                  });
                                }
                              },
                            ),
                            title: Text(_musicList[index][0].toString().toUpperCase()),
                            trailing: IconButton(
                              onPressed: () async {
                                if (isPlaying) {
                                  await _audioPlayer.stop();
                                  await _audioPlayer.release();
                                  state(()=>isPlaying = false);
                                } else {
                                  ByteData bytes = await rootBundle.load(_musicList[index][2]);
                                  Uint8List list = await bytes.buffer.asUint8List();
                                  await _audioPlayer.play(BytesSource(list));
                                  state(()=>isPlaying = true);
                                  _audioPlayer.onPlayerComplete.listen((event) async {
                                    await _audioPlayer.stop();
                                    await _audioPlayer.release();
                                  });
                                }
                              },
                              icon: Icon(isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_fill_outlined),
                            ),
                          );
                        });
                      },
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
