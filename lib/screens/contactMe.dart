import 'package:flutter/material.dart';

class ContactMe extends StatefulWidget {
  @override
  _ContactMeState createState() => _ContactMeState();
}

class _ContactMeState extends State<ContactMe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Me"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Color(0xffFDCF09),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/icon7.jpeg'),
            ),
          ),
          Container(height: 20,),
          Text("Horizon Publishing",style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold,fontSize: 20),),
          Container(height: 20,),
          Text("Email: biblesceneimages@gmail.com"),
        ],
      ),
    );
  }
}
