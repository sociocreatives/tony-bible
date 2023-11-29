import 'package:bibleartwallpaperhd/services/notification.dart';
import 'package:bibleartwallpaperhd/utils/closeKeyboard.dart';
import 'package:bibleartwallpaperhd/utils/constants.dart';
import 'package:bibleartwallpaperhd/widgets/showLoadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldState;

  SettingsTab(this.scaffoldState);

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _durationController = TextEditingController();
  List<bool> _showWeeklyReminder = [true, false];
  late SharedPreferences prefs;
  bool isAndroid = false;
  List<bool> _playSlideshowMusic = [true,false];
  List<bool> _shuffleSlideshowMusic = [true,false];

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Settings Saved"),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> _initPreferences(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initPreferences(context),
        builder: (context, result) {
          if (result.connectionState != ConnectionState.done) {
            return ShowLoadingWidget();
          }

          _durationController.text = '${prefs.getInt('slideShowDuration') ?? Constants.defaultSlideShowDuration}';


          if(prefs.getBool('showWeeklyReminder') == true){
            _showWeeklyReminder[0] = false;
            _showWeeklyReminder[1] = true;
          }

          if(prefs.getBool('playSlideshowMusic') == true){
            _playSlideshowMusic[0] = false;
            _playSlideshowMusic[1] = true;
          }

          if(prefs.getBool('shuffleSlideshowMusic') == true){
            _shuffleSlideshowMusic[0] = false;
            _shuffleSlideshowMusic[1] = true;
          }


          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text(
                  "App Settings",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 30),
                Card(
                  elevation: 8.0,
                  margin: EdgeInsets.all(8),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(child: Text("Show Weekly Wallpaper Change Reminder Notification")),
                        StatefulBuilder(
                            builder: (context, state) {
                              return ToggleButtons(
                                selectedColor: Colors.white,
                                selectedBorderColor: Colors.red,
                                highlightColor: Colors.red,
                                fillColor: Colors.red,
                                children: <Widget>[
                                  Text("OFF"),
                                  Text("ON"),
                                ],
                                onPressed: (int index) async {
                                  if(index == 0){
                                    await prefs.setBool('showWeeklyReminder', false);
                                    NotificationService().cancelNotification();
                                    _showWeeklyReminder[0] = true;
                                    _showWeeklyReminder[1] = false;
                                  }else{
                                    await prefs.setBool('showWeeklyReminder', true);
                                    NotificationService().scheduledNotification();
                                    _showWeeklyReminder[0] = false;
                                    _showWeeklyReminder[1] = true;
                                  }
                                  state(() {});
                                },
                                isSelected: _showWeeklyReminder,
                              );
                            }
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Card(
                  elevation: 8.0,
                  margin: EdgeInsets.all(8),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SlideShow Settings",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: Text("Slideshow Duration: ")),
                            Container(
                              width: 20,
                            ),
                            SizedBox(
                              width: 30,
                              child: TextField(
                                controller: _durationController,
                                textAlignVertical: TextAlignVertical.bottom,
                                maxLength: 2,
                                decoration: InputDecoration(
                                  counter: Offstage(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                ],
                              ),
                            ),
                            Text(" Seconds"),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: Text("Play Music: ")),
                            Container(
                              width: 20,
                            ),
                            StatefulBuilder(
                                builder: (context, state) {
                                  return ToggleButtons(
                                    selectedColor: Colors.white,
                                    selectedBorderColor: Colors.red,
                                    highlightColor: Colors.red,
                                    fillColor: Colors.red,
                                    children: <Widget>[
                                      Text("OFF"),
                                      Text("ON"),
                                    ],
                                    onPressed: (int index) async {
                                      state(() {
                                        if(index == 0){
                                          _playSlideshowMusic = [true,false];
                                          prefs.setBool('playSlideshowMusic',false);
                                        }else{
                                          _playSlideshowMusic = [false,true];
                                          prefs.setBool('playSlideshowMusic',true);
                                        }
                                      });
                                    },
                                    isSelected: _playSlideshowMusic,
                                  );
                                }
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: Text("Shuffle Music: ")),
                            Container(
                              width: 20,
                            ),
                            StatefulBuilder(
                                builder: (context, state) {
                                  return ToggleButtons(
                                    selectedColor: Colors.white,
                                    selectedBorderColor: Colors.red,
                                    highlightColor: Colors.red,
                                    fillColor: Colors.red,
                                    children: <Widget>[
                                      Text("OFF"),
                                      Text("ON"),
                                    ],
                                    onPressed: (int index) async {
                                      state(() {
                                        if(index == 0){
                                          _shuffleSlideshowMusic = [true,false];
                                          prefs.setBool('shuffleSlideshowMusic',false);
                                        }else{
                                          _shuffleSlideshowMusic = [false,true];
                                          prefs.setBool('shuffleSlideshowMusic',true);
                                        }
                                      });
                                    },
                                    isSelected: _shuffleSlideshowMusic,
                                  );
                                }
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: Text("Select Music: ")),
                            Container(
                              width: 20,
                            ),
                            MaterialButton(
                              onPressed: (){
                                Navigator.pushNamed(context, 'selectMusic');
                              },
                              child: Text("Select",style: TextStyle(color: Colors.white),),
                              color: Colors.green,
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: MaterialButton(
                                onPressed: () {
                                  if (_durationController.text.trim().isNotEmpty) {
                                    CloseKeyboard(context);
                                    prefs.setInt('slideShowDuration', int.parse(_durationController.text.trim()));
                                    _showSnackBar(context);
                                  }
                                },
                                child: Text(
                                  "Save Slideshow Settings",
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Colors.green,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          );
        });
  }
}
