import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Name Namerson';
    final mobilePh = '027 452 4318';
    final homePh = "076458524";
    final workPh = '07 645 8524';
    final emailAd = 'namerson@gmail.com';
    final client = 'Thomas Green Industries';



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
              title: Text(client,  style: new TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            ListTile(
              leading: new IconButton(
                icon: new Icon(Icons.note),
                tooltip: 'View client notes',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClientNotes()),
                  );
                },
              ),
              title: Text('Notes',  style: new TextStyle(fontWeight: FontWeight.bold),
              ),
            ),


            new Text(
              "General",
              style: new TextStyle(fontSize:25.0,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w500,
                  fontFamily: "Roboto",
                  height: 2.0),
            ),

            ListTile(
              //leading: Icon(Icons.mobile_screen_share),
              leading: new IconButton(
                icon: new Icon(Icons.mobile_screen_share),
                tooltip: 'Increase volume by 10%',
                //onPressed: () { setState(() { _volume *= 1.1; }); },
              ),
              title: Text(mobilePh + ' (Mobile)', style: new TextStyle(color: Colors.green),
              ),
            ),

            ListTile(
              leading: new IconButton(
                icon: new Icon(Icons.phone),
                tooltip: 'Increase volume by 10%',
                //onPressed: () { setState(() { _volume *= 1.1; }); },
              ),
              title: Text(workPh + ' (Work)', style: new TextStyle(color: Colors.green),
              ),
            ),

            ListTile(
              leading: new IconButton(
                icon: new Icon(Icons.phone),
                tooltip: 'Increase volume by 10%',
                onPressed: () => launch(homePh),
              ),
              title: Text(homePh + ' (Home)',style: new TextStyle(color: Colors.green),
              ),
            ),

            ListTile(
              leading: new IconButton(
                icon: new Icon(Icons.email),
                tooltip: 'Increase volume by 10%',
                //onPressed: () { setState(() { _volume *= 1.1; }); },
              ),
              title: Text(emailAd, style: new TextStyle(color: Colors.blue),),
            ),

          ],
        ),
      ),
    );
  }
}

class ClientNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thomas Green Industries"), //Obvs won't text input the name
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
  
}
