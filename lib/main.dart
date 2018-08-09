import 'package:flutter/material.dart';
import 'ContactPage.dart';
import 'package:validate/validate.dart';

import 'package:http/http.dart' as http; //Used to utilise REST operations
import 'dart:convert'; //Used to convert json into maps

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
  String _urlStart =
      'https://info301.outreach.co.nz/api/0.2/auth/login'; //Uses INFO301 domain
  String _urlUsername = '?username=';
  String _urlLastname = '&password=';

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

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

  String _validateEmail(String value) {
    print("I got called");
    try {
      Validate.isEmail(value);
    } catch (e) {
      return 'The E-mail Address must be a valid email address.';
    }
    return null;
  }

  ///Login Button
  ///Grabs the username and password, adds them to a string to create a URL
  ///The URL is used to access Outreach, and retrieve the API key
  void _loginButton({String pass, String email}) {
    //Will need to sanitise and validate for unexpected characters
    this._username = email;
    this._password = pass;
    print(_username);
    print(_password);

    ///How do we login without specifying the INFO301 prefix? Is there a generic login screen? Are we missing something?
    String _request =
        "https://info301.outreach.co.nz/api/0.2/auth/login/?username=" +
            _username +
            "&password=" +
            _password;
    print(_request);

    ///Retrieving the API Key and storing it as a String (1:25AM, 10/08/18 | Doesn't take incorrect passwords into account)
    http.post(_request).then((response) {
      //Print the API Key, just so we can compare it to the subset String
      print("Original Response body: ${response.body}");
      //Turning the json into a map
      Map apiKeyMap = json.decode(response.body);
      //Converting the map into a string
      String apiKey = apiKeyMap.toString();
      //Trimming the string using string.subset(), should be safe, assumes character positions never change
      apiKey = apiKey.substring(13, (apiKey.length - 2));
      print("This is the API Key: \"" + apiKey +"\"");
    });

    //Send the request and store it in an object

    //Successful login
    emailController.clear();
    passwordController.clear();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactsPage()),
    );
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
              ///Email Text Field
              new TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: new InputDecoration(
                    hintText: "Enter Email",
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 18.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0))),
                //Validation not working atm
                validator: this._validateEmail,
                onSaved: (val) => _username = val,
              ),

              ///Password Text Field
              new TextFormField(
                controller: passwordController,
                obscureText: true,
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
                      _loginButton(
                          email: this.emailController.text,
                          pass: this.passwordController.text);
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
