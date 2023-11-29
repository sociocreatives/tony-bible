import 'package:bibleartwallpaperhd/services/admobService.dart';
import 'package:bibleartwallpaperhd/utils/bibleNumericRef.dart';
import 'package:bibleartwallpaperhd/widgets/showLoadingWidget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BibleView extends StatefulWidget {
  final Map<String,String> map;
  BibleView(this.map);

  @override
  _BibleViewState createState() => _BibleViewState();
}

class _BibleViewState extends State<BibleView> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Book Of " +
              widget.map['book']! +
              " Chapter: " +
              widget.map['chapter']!,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<DataSnapshot>(
        future: FirebaseDatabase.instance.ref()
            .child('Bible')
            .child('Book')
              .child(BibleNumericRef.bibleNumericRefFrom(widget.map['book']!))
            .child('Chapter')
              .child((int.parse(widget.map['chapter']!) - 1).toString())
            .child('Verse')
            .get(),
        builder: (context, snapshot) {
          if(snapshot.data == null){
            return ShowLoadingWidget();
          }

            Object? keys = snapshot.data!.value;

            int fromInt = int.parse(widget.map['fromVerse']!);
            int toInt = int.parse(widget.map['toVerse']!);

          print("Book >> ${widget.map['book']}  Chapter >>> ${widget.map['chapter']} verse >>>> ${widget.map['fromVerse']}  to>>> ${widget.map['toVerse']}");


          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: (toInt+1)-fromInt,
                  itemBuilder: (context,index){

                    return Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 8,
                        margin: EdgeInsets.all(8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Verse: "+(fromInt + index).toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                    Expanded(child: Text("verse")),
                                  Expanded(child: Text(keys[(fromInt + index)-1]['Verse'])),
                                ],
                              ),
                            ],
                          ),
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
