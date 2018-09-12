import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final contactName = 'Name Namerson';

    return new MaterialApp(
      title: 'Contact Page',
      theme: new ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: contactName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;


  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final homePh = "07 645 8524";
    final mobilePh = '027 452 4318';
    final workPh = '07 868 9678';
    final emailAd = 'namerson@gmail.com';
    final client = 'Thomas Green Industries';

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.save), onPressed: () {})
        ],
      ),
      body: new Column(
        children: <Widget>[
          new ListTile(
              leading: new IconButton(
                icon: new Icon(Icons.home),
                tooltip: 'Company',
                onPressed: () {
                },
              ),
              title: Text('Thomas Green Industries',  style: new TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Organisation')
          ),
          new ListTile(
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
            title: Text('Notes',  style: new TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          const Divider(
            height: 1.0,
          ),
          new ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.mobile_screen_share),
              tooltip: 'Contact mobile phone',
              onPressed: () {

                if (Platform.isAndroid) {
                  launch('tel:'+mobilePh);
                } else if (Platform.isIOS) {
//add IOS compatible number here (need to format incoming strings probably)
                }
              },
            ),
            title: Text(mobilePh + ' (Mobile)',style: new TextStyle(color: Colors.green),
            ),
          ),
          new ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.phone),
              tooltip: 'Contact home phone',
              onPressed: () {

                if (Platform.isAndroid) {
                  launch('tel:'+homePh);
                } else if (Platform.isIOS) {
//add IOS compatible number here (need to format incoming strings probably)
                }
              },
            ),
            title: Text(homePh + ' (Home)',style: new TextStyle(color: Colors.green),
            ),
          ),
          new ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.phone),
              tooltip: 'Contact work phone%',
              onPressed: () {

                if (Platform.isAndroid) {
                  launch('tel:'+workPh);
                } else if (Platform.isIOS) {
//add IOS compatible number here (need to format incoming strings probably)
                }
              },
            ),
            title: Text(workPh + ' (Work)',style: new TextStyle(color: Colors.green),
            ),
          ),
          new ListTile(
            leading: new IconButton(
                icon: new Icon(Icons.mail),
                tooltip: 'Increase volume by 10%',
                onPressed: () {

                  if (Platform.isAndroid) {
                    launch('mailto:'+emailAd);
                  } else if (Platform.isIOS) {
                    launch('mailto:'+emailAd);
                  }

                }
            ),
            title: Text(emailAd, style: new TextStyle(color: Colors.blue),
            ),
          )
        ],
      ),
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
