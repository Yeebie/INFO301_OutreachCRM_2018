import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Name Namerson';
    final mobilePh = '027 452 4318';
    final homePh = '07 645 8524';
    final workPh = '07 645 8524';
    final emailAd = 'namerson@gmail.com';



    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),


        body: ListView(
          children: <Widget>[

            ListTile(
              leading: Icon(Icons.home),
              title: Text('Thomas Green Industries'),
            ),

            ListTile(
              leading: Icon(Icons.email),
              title: Text(emailAd),
            ),

            new Text(
              "General",
              style: new TextStyle(fontSize:32.0,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w500,
                  fontFamily: "Roboto"),
            ),

            ListTile(
              leading: Icon(Icons.mobile_screen_share),
              title: Text(mobilePh),
            ),

            ListTile(
              leading: Icon(Icons.phone),
              title: Text(workPh + '(Work)'),
            ),

            ListTile(
              leading: Icon(Icons.phone),
              title: Text(homePh + ' (Home)'),
            ),

          ],
        ),
      ),
    );
  }
}
