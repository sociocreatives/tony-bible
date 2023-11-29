import 'package:bibleartwallpaperhd/homeTabs/selectAppMusic.dart';
import 'package:bibleartwallpaperhd/homeTabs/selectLocalMusic.dart';
import 'package:flutter/material.dart';

class SelectMusic extends StatefulWidget {
  const SelectMusic({required Key key}) : super(key: key);

  @override
  _SelectMusicState createState() => _SelectMusicState();
}

class _SelectMusicState extends State<SelectMusic> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Select Slideshow Music"),
          bottom: TabBar(
            labelColor: Colors.white,
            tabs: [
              Tab(text: "Default Music"),
              Tab(text: "My Music"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SelectAppMusic(),
            SelectLocalMusic()
          ],
        ),
      ),
    );
  }
}
