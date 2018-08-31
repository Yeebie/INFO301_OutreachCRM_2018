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

  ///Temporary for now. We will need to read this in from the user when they
  ///run the app for the first time. We will also need to check that the domain they
  ///entered is valid
  String _domain = "info301";
}

class APIKeyFields {
  String _apiKey = '';
  String _expiry = '';
  bool _passwordVerify = false;
}

class APIKeyValidationFields {
  bool _verify = false;
  String _expiry = '';
  String _oid = '';
}

///Make this an array? How can we do this?
class ContactListFields {
  String _name_processed = '';
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  //Datafields
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  LoginFields _fields = new LoginFields();
  APIKeyFields _apiKeyFields = new APIKeyFields();
  APIKeyValidationFields _apiKeyValidationFields = new APIKeyValidationFields();
  ContactListFields _contactListFields = new ContactListFields();

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
      } else if (value.length > 255) {
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
      } else if (value.length < 6) {
        return "Password must be at least 6 characters";
      } else if (value.length > 255) {
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
        print("");
        print('Login Details');
        print('Username: ${_fields._username}');
        print('Password: ${_fields._password}');
        print('Domain: ${_fields._domain}');
        print('\n \n');

        ///Retrieve the API Key
        _getAPIKeyRetrieval();
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
          new FlutterLogo(
            size: _iconAnimation.value * 100,
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

  ///***************************************************************************
  ///                  A P I   K E Y   R E T R I E V A L
  ///***************************************************************************

  ///Retrieving API Key
  Widget _getAPIKeyRetrieval() {
    //Kind of like a method, will do all sorts of fantastic things in the future
    //Creating the URL that'll query the database for our API Key
    String _requestAPIKeyRetrieval = "https://" +
        _fields._domain +
        ".outreach.co.nz/api/0.2/auth/login/?username=" +
        _fields._username +
        "&password=" +
        _fields._password;
    print("API Key Retrieval");
    print('Creating the URL to generate API Keys via Login Details: ' +
        _requestAPIKeyRetrieval);

    ///This section is delayed until first login attempt has been done, results in invalid verification
    http.post(_requestAPIKeyRetrieval).then((response) {
      //Print the API Key, just so we can compare it to the final result
      print("Original Response body: ${response.body}");
      //Turning the json into a map
      Map apiKeyRetrievalMap = json.decode(response.body);
      //Getting the data from ['data'], which happens to be our array
      APIKeyRetrievalData data =
          new APIKeyRetrievalData.fromJson(apiKeyRetrievalMap['data']);
      //Applying the data from the json to the instance of the Data class
      _apiKeyFields._apiKey = data.getAPIKey();
      _apiKeyFields._expiry = data.getExpiry();

      //Removing null value, just in case we need to use this datafield
      if (data.getPasswordVerify() == false) {
        _apiKeyFields._passwordVerify = false;
      } else {
        _apiKeyFields._passwordVerify = true;
      }

      //Retrieving the API Key from the array
      ///This parts important, we're generating 2 API Keys, this is the one from this login attempt
      print("Printing getAPIKey()");
      print(_apiKeyFields._apiKey);
      print("Printing getExpiry()");
      print(_apiKeyFields._expiry);
      print("Printing getPasswordVerify()");
      print(_apiKeyFields._passwordVerify);
      print('\n \n');

      if (_apiKeyFields._passwordVerify == false) {
        showDialogParent("Baka!", "Couldn't verify username or password.");
      } else {
        ///Verify API Key
        _getAPIKeyVerification();
      }
    });
  }

  ///***************************************************************************
  ///                  A P I   K E Y   V A L I D A T I O N
  ///***************************************************************************

  ///Validating API Key
  Widget _getAPIKeyVerification() {
    //Next step is to verify the key, retrieve the user etc
    print('API Key Validation');
    String _requestAPIKeyVerification = "https://" +
        _fields._domain +
        ".outreach.co.nz/api/0.2/auth/verify/?apikey=" +
        _apiKeyFields._apiKey;
    print('API Validation URL: ' + _requestAPIKeyVerification);

    http.post(_requestAPIKeyVerification).then((response) {
      //Print the API Key, just so we can compare it to the subset String
      print("API Key Verification Response: ${response.body}");
      //Turning the json into a map
      Map apiKeyVerificationMap = json.decode(response.body);
      //Getting the data from ['data'], which happens to be our array
      APIKeyValidationData data =
          new APIKeyValidationData.fromJson(apiKeyVerificationMap['data']);
      //Applying the data from the json to the instance of the Data class
      _apiKeyValidationFields._verify = data.getVerify();
      _apiKeyValidationFields._expiry = data.getExpiry();
      _apiKeyValidationFields._oid = data.getOid();

      //Defining regex to search for key
      RegExp apiPattern = new RegExp(
        r"([a-z0-9]){32}",
        caseSensitive: false,
        multiLine: false,
      );

      print("Current API Key");
      print(_apiKeyFields._apiKey);
      print("Printing Verify");
      print(_apiKeyValidationFields._verify);
      print("Printing Expiry");
      print(_apiKeyValidationFields._expiry);
      print("Printing OID");
      print(_apiKeyValidationFields._oid);

      if (apiPattern.hasMatch(_apiKeyFields._apiKey)) {
        print("API Key Matches Format");
        print("\n\n");
        _getContactsList();
      } else {
        showDialogParent(
            "Is this statement even possible?", "API Key isn't valid.");
      }
    });
  }

  ///***************************************************************************
  ///             C O N T A C T S   L I S T   R E T R I E V A L
  ///***************************************************************************

  ///Loading the Contacts List into a Collection
  Widget _getContactsList() {
    Map contactListMap;
    print('Retrieving Contacts List\n');
    String _requestContactList = "https://" +
        _fields._domain +
        ".outreach.co.nz/api/0.2/query/user?apikey=" +
        _apiKeyFields._apiKey +
        "&properties=%5B%27name_processed%27%5D&conditions=%5B%5B%27status%27,%27=%27,%27O%27%5D,%5B%27oid%27,%27%3E=%27,%27100%27%5D%5D";
//    Display [user's names], if their [status is open] and their [oid is larger than 100]
//    Dart Encode doesn't convert apostrophes, it may be easier to write the query by hand, then CTRL + H all the necessary bits
//    Can we do this conversion cleanly in app?
//    %5B = "["
//    %5D = "]"
//    %27 = "'"
//    %20 = " "

    print('Get Contact List URL: ' + _requestContactList);

    ///This section is temporary, for some reason, some of the code below the post doesn't execute
    ///Display Contacts Page
    usernameController.clear();
    passwordController.clear();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactsPage()),
    );

    http.post(_requestContactList).then((response) {
      //Print the API Key, just so we can compare it to the subset String
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
      Map map = new Map();
      contactListMap['data'].forEach((dynamic) {
        print('${contactListMap['data'].indexOf(dynamic)}: $dynamic');
        map[contactListMap['data'].indexOf(dynamic)] =
            '${contactListMap['data'].indexOf(dynamic)}: $dynamic';
      });

      ///Maybe grab OID and use that as the Map Key?
      print("Printing all members that were loaded into the map");
      for (int i = 0; i < map.length; i++) {
        print(map[i]);
      }
    });
  }
}

///API Key Retrieval
///Represents the bits inside the nested json
class APIKeyRetrievalData {
  String key;
  String expiry;
  bool passwordVerify;

  //Constructor
  APIKeyRetrievalData({this.key, this.expiry, this.passwordVerify});

  //Getter method
  String getAPIKey() {
    return key;
  }

  //Getter method
  String getExpiry() {
    return expiry;
  }

  //Getter method
  bool getPasswordVerify() {
    return passwordVerify;
  }

  //Soft of like a method that'll be executed somewhere
  factory APIKeyRetrievalData.fromJson(Map<String, dynamic> json) {
    return APIKeyRetrievalData(
        key: json['key'],
        expiry: json['expiry'],
        passwordVerify: json['password']);
  }
}

///Represents the base json, the data array
class APIKeyRetrievalJson {
  //Datafields
  APIKeyRetrievalData data;

  //Constructor
  APIKeyRetrievalJson({this.data});

  //Soft of like a method that'll be executed somewhere
  factory APIKeyRetrievalJson.fromJson(Map<String, dynamic> parsedJson) {
    return APIKeyRetrievalJson(
        data: APIKeyRetrievalData.fromJson(parsedJson['data']));
  }
}

///API Key Validation
///Represents the bits inside the nested json
class APIKeyValidationData {
  bool verify;
  String expiry;
  String oid;

  //Constructor
  APIKeyValidationData({this.verify, this.expiry, this.oid});

  //Getter method
  bool getVerify() {
    return verify;
  }

  //Getter method
  String getExpiry() {
    return expiry;
  }

  //Getter method
  String getOid() {
    return oid;
  }

  //Soft of like a method that'll be executed somewhere
  factory APIKeyValidationData.fromJson(Map<String, dynamic> json) {
    return APIKeyValidationData(
        verify: json['verify'], expiry: json['expiry'], oid: json['oid']);
  }
}

///Data is different between requests, we need to copy this format multiple times
///Represents the base json, the data array
class APIKeyValidationJson {
  //Datafields
  APIKeyValidationData data;

  //Constructor
  APIKeyValidationJson({this.data});

  //Soft of like a method that'll be executed somewhere
  factory APIKeyValidationJson.fromJson(Map<String, dynamic> parsedJson) {
    return APIKeyValidationJson(
        data: APIKeyValidationData.fromJson(parsedJson['data']));
  }
}

///Contact List Retrieval
///Represents the bits inside the nested json
class ContactListData {
  String name_processed;

  //Constructor
  ContactListData({this.name_processed});

  //Getter method
  String getNameProcessed() {
    return name_processed;
  }

  //Soft of like a method that'll be executed somewhere
  factory ContactListData.fromJson(Map<String, dynamic> json) {
    return ContactListData(name_processed: json['name_processed']);
  }
}

///Data is different between requests, we need to copy this format multiple times
///Represents the base json, the data array
class ContactListJson {
  //Datafields
  ContactListData data;

  //Constructor
  ContactListJson({this.data});

  //Soft of like a method that'll be executed somewhere
  factory ContactListJson.fromJson(Map<String, dynamic> parsedJson) {
    return ContactListJson(data: ContactListData.fromJson(parsedJson['data']));
  }
}
