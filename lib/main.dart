import 'package:flutter/material.dart';
import 'package:outreachcrm_app/ContactPage.dart';
import 'package:outreachcrm_app/ContactPage.dart';
import 'package:validate/validate.dart';

///Used to utilise REST operations
import 'package:http/http.dart' as http;

///Used for API Key Retrieval
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; //Converts Json into Map

import 'package:outreachcrm_app/SupportClasses.dart';

void main() {
  runApp(new MyApp());
  print("\n");
  print("Outreach Mobile Application");
  print("Branch: UI_Pagination");
  print("Build:  Sprint 2 Release | Pre-UI & Cache Overhaul");
  print("Task:   Updating kContact after retrieving new data");
  print("NEW PAGE");
  print("\n");
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
  String nameProcessed = '';
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin{
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
        showDialogParent(
            "Incorrect Login.", "Couldn't verify username or password.");
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
        showDialogParent("Incorrect API Key.", "API Key isn't valid.");
      }
    });
  }

  ///***************************************************************************
  ///             C O N T A C T S   L I S T   R E T R I E V A L
  ///***************************************************************************

  ///Loading the Contacts List into a Collection
  Widget _getContactsList() {
    print('Retrieving Contacts List\n');

    ///Specify the API Query here, type it according to the API Specification, the app'll convert it to encoded HTML
    String apikey = "?apikey=" + _apiKeyFields._apiKey;
    String properties = "&properties=" + "['name_processed','oid','o_company']";
    String conditions =
        "&conditions=" + "[['status','=','O'],['oid','>=','100']]";
    String order = "&order=" +
        "[['o_first_name','=','DESC'],['o_last_name','=','DESC']]"; //[[Primary sort],[Secondary sort]], Ordered by o_first_name, o_first_name are ordered by o_last_name
    String limit = "&limit=" +
        "[24,0]"; //[Load this amount of contacts at a time, Start from this index]. Loading 25 at a time, loads from index 0 to index 24, baka.

    ///Specifying the URL we'll make to call the API
    String _requestContactList = "https://" +
        _fields._domain +
        ".outreach.co.nz/api/0.2/query/user" +
        (apikey + properties + conditions + order + limit);

    ///Encoding the String so its HTML safe
    _requestContactList = _requestContactList.replaceAll("[", "%5B");
    _requestContactList = _requestContactList.replaceAll("]", "%5D");
    _requestContactList = _requestContactList.replaceAll("'", "%27");
    _requestContactList = _requestContactList.replaceAll(">", "%3E");
    print('Get Contact List URL: ' + _requestContactList);

    ///Send an API request, load all of the json into a map
    http.post(_requestContactList).then((response) {
      //Print the API Key, just so we can compare it to the subset String
      print("Contact List Response:");
      print(response.body);
      List<Contact> contactsList = new List();
      //Turning the json into a map
      final contactListMap = json.decode(response.body);
      ContactListJson contactListJson =
          new ContactListJson.fromJson(contactListMap);
      print("\n\n");

      ///Creates a new contact filled with data, adds it to List<Contact>
      for (ContactListData data in contactListJson.data) {
        Contact contact = new Contact();
        contact.setFullName(data.getNameProcessed());
        contact.setOid(data.getOid());
        contact.setCompany(data.getCompany());
        contactsList.add(contact);
      }

      ///Printing the contactList, sanity check
      print("Printing contactsList");
      int i = 0;
      while (i < contactsList.length) {
        print(contactsList[i].getFullName());
        i++;
      }
      print('\n');

      ///Send the contactsList to be displayed on the ContactsPage
      usernameController.clear();
      passwordController.clear();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactsPageApp(_apiKeyFields._apiKey, _fields._domain, contacts: contactsList)),
      );
    });
  }
}
