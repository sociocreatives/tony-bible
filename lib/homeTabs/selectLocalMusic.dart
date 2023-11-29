import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bibleartwallpaperhd/widgets/showLoadingWidget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SelectLocalMusic extends StatefulWidget {
  const SelectLocalMusic({Key? key}) : super(key: key);

  @override
  _SelectLocalMusicState createState() => _SelectLocalMusicState();
}

class _SelectLocalMusicState extends State<SelectLocalMusic> {
  AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, String> _savedLocalMusic = {};
  FilePicker filePicker = FilePicker.platform;
  String? filePath;


  Future<void> _getLocalMusic(context) async {
   try{
     _savedLocalMusic.clear();
     Directory directory = await getApplicationDocumentsDirectory();
     filePath = (await Directory('${directory.path}/music/').create(recursive: true)).path;
     List<FileSystemEntity> fileList = Directory("$filePath").listSync();
     for(FileSystemEntity file in fileList){
       _savedLocalMusic.addAll({'${basename(file.path)}':'${file.path}'});
     }
   }catch(e,s){
     print(e);
     print(s);
   }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final dir = Directory(filePath!);
                        dir.deleteSync(recursive: true);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      FilePickerResult? result = await filePicker.pickFiles(
                        allowMultiple: true,
                        type: FileType.audio,
                        dialogTitle: "Select Music",
                      );
                      if (result != null) {
                        List<PlatformFile> files = result.files;
                        for (PlatformFile file in files) {
                          if(Platform.isIOS){
                            await File(file.path!)
                                .copy('$filePath/${file.name}');
                          }else{
                            await File(file.path!).copy(
                                '$filePath/${file.name}.${file.extension}');
                          }
                        }
                        setState(() {});
                      }
                    },
                    child: Text(
                      "Upload Music",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
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
                  future: _getLocalMusic(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) return ShowLoadingWidget();
                    List<String> keys = _savedLocalMusic.keys.toList();

                    return ListView.builder(
                      itemCount: keys.length,
                      itemBuilder: (context, index) {
                        bool isPlaying = false;
                        return StatefulBuilder(builder: (context, state) {
                          return ListTile(
                            leading: IconButton(
                              onPressed: () async {
                                if (isPlaying) {
                                  await _audioPlayer.stop();
                                  await _audioPlayer.release();
                                  state(() {
                                    isPlaying = false;
                                  });
                                } else {
                                  Uint8List list = await File.fromUri(Uri.parse(
                                          _savedLocalMusic[keys[index]]!))
                                      .readAsBytes();
                                  await _audioPlayer.play(BytesSource(list));
                                  state(() {
                                    isPlaying = true;
                                  });
                                  _audioPlayer.onPlayerComplete.listen((event) async {
                                    await _audioPlayer.stop();
                                    await _audioPlayer.release();
                                  });
                                }
                              },
                              icon: Icon(isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_fill_outlined),
                            ),
                            title: Text(keys[index].toString()),
                            trailing: TextButton(
                              onPressed: (){
                                File.fromUri(Uri.parse(
                                        _savedLocalMusic[keys[index]]!))
                                    .delete();
                                setState(() {});
                              },
                              child: Text("Remove"),
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
