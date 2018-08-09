import 'package:flutter/material.dart';
import 'ContactPage.dart';
import 'package:validate/validate.dart';

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

  void _loginButton({String pass, String email}) {
   //Will need to sanitise and validate for unexpected characters
    this._username = email;
    this._password = pass;
    print(_username);
    print(_password);

    String request = "https://info301.outreach.co.nz/api/0.2/auth/login/?username=" + _username + "&password=" + _password;

    //Send the request and store it in an object


    //Successful login
    emailController.clear();
    passwordController.clear();
    Navigator.push(context,MaterialPageRoute(builder: (context) => ContactsPage()),);
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
                      pass: this.passwordController.text
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
