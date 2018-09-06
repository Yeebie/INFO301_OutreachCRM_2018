import 'package:flutter/material.dart';
import 'ContactPage.dart';
import 'package:validate/validate.dart';

///Used to utilise REST operations
import 'package:http/http.dart' as http;

///Used for API Key Retrieval
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; //Converts Json into Map

void main() {
  runApp(new MyApp());
  //loadCrossword();
}

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

  Map<String, dynamic> apiKey;

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

  //Not used anymore since Andrew said that usernames can be emails or alphanumeric
  //See _validateUsername for current validator
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

  String _validateUsername(String value) {
    RegExp userNamePattern = new RegExp(
      r"^[a-zA-Z0-9@.]*$",
      caseSensitive: false,
      multiLine: false,
    );
    if (userNamePattern.hasMatch(value)) {
      if (value == "") {
        return "Please enter a username";
      }
      else if (value.length > 255) {
        return "Your username is too long";
      }
    } else {
      return 'Invalid characters in username';
    }
    return null;
  }


  String _validatePassword(String value) {
    RegExp passwordPattern = new RegExp(
      r"^[a-zA-Z0-9]*$",
      caseSensitive: false,
      multiLine: false,
    );
    if (passwordPattern.hasMatch(value)) {
      if (value == "") {
        return "Please enter a password";
      }
      else if (value.length < 6) {
        return "Password must be at least 6 characters";
      }
      else if (value.length > 255) {
        return "Your password is too long";
      }
    } else {
      return 'Invalid characters in password';
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
        print('Login Details');
        print('Username: ${_fields._username}');
        print('Password: ${_fields._password}');
        print('Domain: ${_fields._domain}');
        print('\n \n');

        ///Retrieve the API Key
        _getAPIKeyRetrieval();

        //Defining regex to search for key
        RegExp apiPattern = new RegExp(
          r"([a-z0-9]){32}",
          caseSensitive: false,
          multiLine: false,
        );

        //If the pattern matches the key we got a valid request!
        if (apiPattern.hasMatch(_fields._apiKey)) {
          print("I'm logging in");

          ///Verify API Key
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
      }
    } catch (e) {
      showDialogParent("Error", "Something bad happened");
      print(e);
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
          new Image.asset('assets/OutreachCRM_vert_logo.jpg',
            width: 175.0,
            height: 175.0,

          ),
          new Form(
              key: this._formKey,
              child: new Column(
                children: <Widget>[
                  ///Email Text Field
                  new TextFormField(

                    keyboardType: TextInputType.text,
                    controller: usernameController,
                    decoration: new InputDecoration(
                        hintText: "Enter Username",
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 18.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0))),
                    validator: this._validateUsername,
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
                            validator: this._validatePassword,
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

  ///Retrieving API Key
  Widget _getAPIKeyRetrieval() {
    //Kind of like a method, will do all sorts of fantastic things in the future
    Future<String> _loadAPIKeyAsset() async {
      //Creating the URL that'll query the database for our API Key
      String _requestAPIKeyRetrieval = "https://" +
          _fields._domain +
          ".outreach.co.nz/api/0.2/auth/login/?username=" +
          _fields._username +
          "&password=" +
          _fields._password;
      print('Creating the URL to generate API Keys via Login Details: ' +
          _requestAPIKeyRetrieval);
      print('\n\n');

      http.post(_requestAPIKeyRetrieval).then((response) {
        print("API Key Retrieval");
        //Print the API Key, just so we can compare it to the subset String
        print("Original Response body: ${response.body}");
        //Turning the json into a map
        Map jsonResponse = json.decode(response.body);
        //Getting the data from ['data'], which happens to be our array
        Data data = new Data.fromJson(jsonResponse['data']);
        //Retrieving the API Key from the array
        print("Printing getAPIKey()");
        print(data.getAPIKey());
        //Applying the API Key to the API Key Field
        _fields._apiKey = data.getAPIKey();
      });
    }

    //Calling the method we just wrote
    _loadAPIKeyAsset();
  }

  ///Validating API Key
  ///Currently responds with {"data":{"verify":false},"error":"Contact deactivated"}, our account may be archived or deleted
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

///Represents the bits inside the nested json
class Data {
  String key;
  String expiry;

  //Constructor
  Data({this.key, this.expiry});

  //Getter method
  String getAPIKey() {
    return key;
  }

  //Soft of like a method that'll be executed somewhere
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(key: json['key'], expiry: json['expiry']);
  }
}

///Represents the base json, the data array
class APIKeyJson {
  //Datafields
  Data data;

  //Constructor
  APIKeyJson({this.data});

  //Soft of like a method that'll be executed somewhere
  factory APIKeyJson.fromJson(Map<String, dynamic> parsedJson) {
    return APIKeyJson(data: Data.fromJson(parsedJson['data']));
  }
}

