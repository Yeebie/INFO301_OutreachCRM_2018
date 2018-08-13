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

class LoginFields {
  String _username = '';
  String _password = '';
  String _apiKey = '';

  ///Temporary for now. We will need to read this in from the user when they
  ///run the app for the first time. We will also need to check that the domain they
  ///entered is valid
  String _domain = "info301";
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  //Datafields
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  LoginFields _fields = new LoginFields();

  String _urlStart =
      'https://info301.outreach.co.nz/api/0.2/auth/login'; //Uses INFO301 domain
  String _urlUsername = '?username=';
  String _urlLastname = '&password=';

  final TextEditingController usernameController = new TextEditingController();
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
    try {
      Validate.isEmail(value);
    } catch (e) {
      if (value == "") {
        return "Please enter a username";
      } else {
        return 'The username must be a valid email address.';
      }
    }
    return null;
  }

  void showDialogParent(String title, String content) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(title),
              content: new Text(content),
            ));
  }

  void _loginButton() {
    //This checks if the form validates
    try {
      if (this._formKey.currentState.validate()) {
        //Saves the form
        this._formKey.currentState.save();
        print('Username: ${_fields._username}');
        print('Password: ${_fields._password}');
        print('Domain: ${_fields._domain}');
        print('\n \n');

        ///How do we login without specifying the INFO301 prefix? Is there a generic login screen? Are we missing something?
        ///
        ///From my research there are multiple domains for Outreach. Such as https://mexifoods.outreach.co.nz/.
        ///We will need to obtain this from the user and check that the domain is a valid outreach domain before making any API requests
        ///I know a way to do this but we will have to go back to Andrew with some questions. I have some other questions regarding the API too.
        String _request = "https://" +
            _fields._domain +
            ".outreach.co.nz/api/0.2/auth/login/?username=" +
            _fields._username +
            "&password=" +
            _fields._password;
        print('Creating the URL to generate API Keys via Login Details');
        print('URL: ' + _request);

        ///A loading animation while we wait for the response from the request would be nice

        ///Retrieving the API Key and storing it as a String (1:25AM, 10/08/18 | Doesn't take incorrect passwords into account)
        //String apiKey = "";
        http.post(_request).then((response) {
          //Print the API Key, just so we can compare it to the subset String
          print("Original Response body: ${response.body}");
          //Turning the json into a map
          Map apiKeyMap = json.decode(response.body);
          //Converting the map into a string
          _fields._apiKey = apiKeyMap.toString();
          //Trimming the string using string.subset(), should be safe, assumes character positions never change
          _fields._apiKey =
              _fields._apiKey.substring(13, (_fields._apiKey.length - 2));
          print("Extracted API Key: \"" + _fields._apiKey + "\"");

          //Defining regex to search for key
          RegExp apiPattern = new RegExp(
            r"([a-z0-9]){32}",
            caseSensitive: false,
            multiLine: false,
          );

          //If the pattern matches the key we got a valid request!
          if (apiPattern.hasMatch(_fields._apiKey)) {
            print("I'm logging in");

            ///Insert Verify API Key stuff
            _getAPIKeyVerification();

            ///Get Contacts List
            _getContactsList();

            //Successful login
            usernameController.clear();
            passwordController.clear();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactsPage()),
            );
          }
          //Otherwise unsuccessful login
          else {
            showDialogParent(
                "Incorrect login", "Couldn't verify username or password");
          }
        });
      }
    } catch (e) {
      showDialogParent("Error", "Something bad happened");
    }
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
              key: this._formKey,
              child: new Column(
                children: <Widget>[
                  ///Email Text Field
                  new TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: usernameController,
                    decoration: new InputDecoration(
                        hintText: "Enter Username",
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 18.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0))),
                    validator: this._validateEmail,
                    onSaved: (val) => this._fields._username = val,
                  ),

                  ///Password Text Field
                  new TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: new InputDecoration(
                        hintText: "Enter Password",
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 18.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0))),
                    onSaved: (val) => this._fields._password = val,
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
                          _loginButton();
                        },
                        color: Colors.lightBlueAccent,
                        child: Text('Log in',
                            style: TextStyle(color: Colors.white)),
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

  ///Validating API Key
  Widget _getAPIKeyVerification() {
    //Next step is to verify the key, retrieve the user etc
    print('\n \n');
    print('API Key Validation\n');
    String _requestAPIKeyVerification = "https://" +
        _fields._domain +
        ".outreach.co.nz/api/0.2/auth/verify/?apikey=" +
        _fields._apiKey;
    print('API Validation URL: ' + _requestAPIKeyVerification);
    print('\n \n');

    http.post(_requestAPIKeyVerification).then((response) {
      //Print the API Key, just so we can compare it to the subset String
      print("API Key Verification Response: ${response.body}");
      //Turning the json into a map
      Map apiKeyVerificationMap = json.decode(response.body);
      print(apiKeyVerificationMap);
      print('\n \n');
      return (apiKeyVerificationMap);
    });
  }

  ///Loading the Contacts List into a Collection
  Widget _getContactsList() {
    Map contactListMap;
    print('Retrieving Contacts List\n');
    String _requestContactList = "https://" +
        _fields._domain +
        ".outreach.co.nz/api/0.2/query/user?apikey=" +
        _fields._apiKey +
        "&properties=%5B%27name_processed%27%5D&conditions=%5B%5B%27status%27,%27=%27,%27O%27%5D,%5B%27oid%27,%27%3E=%27,%27100%27%5D%5D";
//    Display [user's names], if their [status is open] and their [oid is larger than 100]
//    Encode doesn't convert apostrophes, it may be easier to write the query by hand, then CTRL + H all the necessary bits
//    %5B = [
//    %5D = ]
//    %27 = '

    print('Get Contact List URL: ' + _requestContactList);
    print('\n \n');

    http.post(_requestContactList).then((response) {
      //Print the API Key, just so we can compare it to the subset String
      print('\n \n');
      print("Contact List Response:");
      print(response.body);

      //Turning the json into a map
      Map<String, dynamic> contactListMap = json.decode(response.body);
      print("Contact List Map: ");
      print(contactListMap);
      print('\n \n');

      print("Printing all contacts in Map");
      print(contactListMap['data']);
      print('\n \n');
    });
  }
}
