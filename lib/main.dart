import 'package:flutter/material.dart';
import 'ContactPage.dart';

import 'package:http/http.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new LoginPage(),
        theme: new ThemeData(primarySwatch: Colors.lightBlue));
  }
}

class LoginPage extends StatefulWidget {
  @override
  State createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  //Datafields
  String _username = '';
  String _password = '';

  AnimationController _iconAnimationController;
  Animation<double> _iconAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _iconAnimationController = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 1000));
    _iconAnimation = new CurvedAnimation(
        parent: _iconAnimationController, curve: Curves.easeOut);

    _iconAnimation.addListener(() => this.setState(() {}));
    _iconAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      backgroundColor: Colors.white,
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new FlutterLogo(
            size: _iconAnimation.value * 100,
          ),
          new Form(
              child: new Column(
            children: <Widget>[
              new TextFormField(
                decoration: new InputDecoration(
                    hintText: "Enter Email",
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 18.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0))),
                onSaved: (val) => _username = val,
              ),
              new TextFormField(
                decoration: new InputDecoration(
                    hintText: "Enter Password",
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 18.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0))),
                onSaved: (val) => _password = val,
              ),
              new Padding(
                padding: const EdgeInsets.all(20.0),
                child: Material(
                  borderRadius: BorderRadius.circular(30.0),
                  shadowColor: Colors.lightBlueAccent.shade100,
                  elevation: 5.0,
                  child: MaterialButton(
                    minWidth: 200.0,
                    height: 42.00,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ContactsPage()),
                      );
                    },
                    color: Colors.lightBlueAccent,
                    child:
                        Text('Log in', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              const FlatButton(
                child: Text(
                  "Forgot password?",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: null,
              )
            ],
          )),
        ],
      ),
    );
  }
}
