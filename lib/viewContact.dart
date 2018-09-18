import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

//Define "root widget"
//one-line function

class viewContact extends StatelessWidget {

  final homePh = "07 645 8524";
  final mobilePh = '027 452 4318';
  final workPh = '07 868 9678';
  final emailAd = 'namerson@gmail.com';
  final client = 'Thomas Green Industries';

  @override
  Widget build(BuildContext context) {

    //build function returns a "Widget"
    var card = new Card(
      child: new Column(

        children: <Widget>[

          new ListTile(
            leading: new Icon(Icons.account_box, color: Colors.blue,size: 26.0,),
            title: new Text(client
              ,style: new TextStyle(fontWeight: FontWeight.bold),),
            subtitle: new Text("Organisation"),
          ),
          new Divider(color: Colors.blue,indent: 16.0,),
          new ListTile(
            leading: new IconButton(
                icon: new Icon(Icons.email, color: Colors.blue, size: 26.0,),
                tooltip: '',
                padding: new EdgeInsets.all(0.0),
                onPressed: () {

                  if (Platform.isAndroid) {
                    launch('mailto:'+emailAd);
                  } else if (Platform.isIOS) {
                    launch('mailto:'+emailAd);
                  }

                }
            ),
            //leading: new Icon(Icons.email, color: Colors.blue, size: 26.0,),
            title: new Text(emailAd
              ,style: new TextStyle(fontWeight: FontWeight.w400),),
          ),



          new ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.phone, color: Colors.blue,size: 26.0,),
              tooltip: 'Contact work phone%',
              onPressed: () {

                if (Platform.isAndroid) {
                  launch('tel:'+workPh);
                } else if (Platform.isIOS) {
//add IOS compatible number here (need to format incoming strings probably)
                }
              },
            ),
            title: Text(workPh,style: new TextStyle(color: Colors.black),
            ),
            subtitle: new Text("Work Phone"),
          ),


          new ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.phone, color: Colors.blue,size: 26.0,),
              tooltip: 'Contact mobile phone%',
              onPressed: () {

                if (Platform.isAndroid) {
                  launch('tel:'+mobilePh);
                } else if (Platform.isIOS) {
//add IOS compatible number here (need to format incoming strings probably)
                }
              },
            ),
            title: Text(mobilePh,style: new TextStyle(color: Colors.black),
            ),
            subtitle: new Text("Mobie Phone"),
          ),

          new ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.note, color: Colors.blue,size: 26.0,),
              tooltip: 'View client notes',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientNotes()),
                );

              },
            ),
            title: Text('Client Notes',  style: new TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          new Divider(color: Colors.blue,indent: 16.0,),

          new ListTile(
            leading: new Icon(Icons.home, color: Colors.blue,size: 26.0,),
            title: Text("Organisation Details",style: new TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),

          ),
        ],

      ),
    );

    final sizedBox = new Container(

      margin: new EdgeInsets.only(left: 10.0, right: 10.0),
      child: new SizedBox(
        height: 520.0,
        child: card,
      ),
      alignment: Alignment(-1.0, -1.0),
    );

    final center = new Center(
      child: sizedBox,

    );

    return new MaterialApp(
        title: "",
//      home: new Text("Add Google fonts to Flutter App")
        home: new Scaffold(appBar: new AppBar(
            title: new Text("Contact Details")
        ),
          body: center,


        )
    );
  }
}

class ClientNotes extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Thomas Green Industries"),
          actions: <Widget>[
            new IconButton(icon: const Icon(Icons.keyboard_backspace), onPressed: () {Navigator.pop(context);})
          ], // won't text input the name
        ),

        body:
        new Card(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                leading: const Icon(Icons.note),
                title: const Text('Note title?'),
                subtitle: const Text('Preview note contents  contents  contents  contents  contents  contents '),
              ),
              new ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: new ButtonBar(
                  children: <Widget>[
                    new FlatButton(
                      child: const Text('View note'),
                      onPressed: () { /* ... */ },
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}