import 'package:flutter/material.dart';
import 'ContactPage.dart';
import 'package:validate/validate.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

///Used to utilise REST operations
import 'package:http/http.dart' as http;

///Used for API Key Retrieval
import 'dart:async' show Future, Timer;
import 'package:flutter/services.dart';
import 'dart:convert'; //Converts Json into Map

import 'package:outreachcrm_app/Contact.dart';
import 'package:splashscreen/splashscreen.dart';

/// used for caching
import 'package:outreachcrm_app/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Contact> contacts;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Signika',
      ),
      home: LoginPage(
        loginFields: LoginFields(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final LoginFields loginFields;
  LoginPage({@required this.loginFields});
  @override
  _LoginPageState createState() => _LoginPageState(loginFields: loginFields);
}

class LoginFields {
  String _username = '';
  String _password = '';
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

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  /// cache login variables
  Future<SharedPreferences> _sPrefs = SharedPreferences.getInstance();
  // boolean to lock cache check when logging in
  bool _attemptingAutoLogin = false;

  ///Data fields
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final LoginFields loginFields;
  _LoginPageState({this.loginFields});

  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  APIKeyFields _apiKeyFields = new APIKeyFields();
  APIKeyValidationFields _apiKeyValidationFields = new APIKeyValidationFields();
  ContactListFields _contactListFields = new ContactListFields();


  Map<String, dynamic> apiKey;

  //triggers modal loading overlay
  static bool _inAsyncCall = false;
  //Puts app in demo mode (If you want to switch out the mode then you have
  //change the boolean and rerun the app. If someone finds a fix that would be
  //great)
  bool _demoMode = false;
  @override
  void initState() {
    super.initState();

    // call this to clear cache
    _clearLoginDetails();

    new Timer(new Duration(milliseconds: 200), () {
      checkLoggedIn();
    });
  }


  bool _wifiEnabled = true;

  //Not used anymore since Andrew said that user names can be emails or alphanumeric
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

  String _validateUserName(String value) {
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

  void _checkWifi() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        _wifiEnabled = true;
      }
    } on SocketException catch (_) {
      print('not connected');
      _wifiEnabled = false;
    }
  }

  void showDialogParent(String title, String content) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(title),
              content: new Text(content),
            ));
  }

  void _forgotPassword() async {
    String url = 'https://' +
        loginFields._domain +
        '.outreach.co.nz/?Na=forgot-password-public';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _login() {

    _checkWifi();
    //Future.delayed(const Duration(seconds: 3));
    /*
    if(_wifiEnabled) {
      showDialogParent("Yay", "You have wifi!");
    }
    else {
      showDialogParent("Boo", "You don't have wifi!");
    }
    */
    try {
      if(_wifiEnabled) {
        if ((_loginFormKey.currentState.validate()) ||
            (_demoMode && !_loginFormKey.currentState.validate())) {

            _loginFormKey.currentState.save();

          // dismiss keyboard
          FocusScope.of(context).requestFocus(new FocusNode());

          // start the modal progress HUD
          setState(() {
            _inAsyncCall = true;
            _getAPIKeyRetrieval();
          });

            /*
        Just used for debugging
        print("");
        print('Login Details');
        print('Username: ${loginFields._username}');
        print('Password: ${loginFields._password}');
        print('Domain: ${loginFields._domain}');
        print('\n \n');
         */

          // set the cache with the validated login fields
          _setLoginDetails(loginFields._domain, loginFields._username, loginFields._password);

          // Buy us some time while logging in
          Future.delayed(Duration(seconds: 5), () {
            setState(() {
              // stop the modal progress HUD
              _inAsyncCall = false;
            });
          });
        }
      }
    } catch (e) {
      showDialogParent("Error", "Couldn't login");
      print(e);
    }
  }


  ///***************************************************************************
  ///                     A U T O   L O G I N
  ///***************************************************************************

  /// method used to clear cache on logout
  void _clearLoginDetails() {
    print("------------------");
    print("CLEARING DETAILS IN CACHE");
    print("------------------");

    Util.removeCacheItem('domain');
    Util.removeCacheItem('username');
    Util.removeCacheItem('password');
  }

  /// method to set the cache values for login details.
  void _setLoginDetails(String domain, String username, String password){
    // check if the field is being passed null
    if(domain != "" && username != "" && password != "") {
      print("------------------");
      print("SAVING DETAILS IN CACHE");
      print("------------------");

      Util.setString('domain', domain);
      Util.setString('username', username);
      Util.setString('password', password);
    }
  }

  Future checkLoggedIn() async {
    // instantiate shared preferences (cache)
    SharedPreferences prefs = await _sPrefs;

    // attempt to read in cache values, return null if not found
    String _cachedDomain = (prefs.getString('domain') ?? null);
    String _cachedUsername = (prefs.getString('username') ?? null);
    String _cachedPassword = (prefs.getString('password') ?? null);

    // check if the login details are in cache
    if (_cachedDomain != null && _cachedUsername != null
        && _cachedPassword != null){

      print("------------------");
      print("FOUND DETAILS IN CACHE");
      print("------------------");
      loginFields._domain = _cachedDomain;
      loginFields._username = _cachedUsername;
      loginFields._password = _cachedPassword;

      print(_cachedDomain);
      print(_cachedUsername);
      print(_cachedPassword);
      print("------------------");

      // attempt the login

      // if we are not currently trying to login
      if(_attemptingAutoLogin == false) {
        // attempt to get API key
          _getAPIKeyRetrieval();
          _attemptingAutoLogin = true;
        // push to contacts page
      }


    } else { // else return you found nothing

      print("------------------");
      print("FOUND NO DETAILS IN CACHE");
      print("------------------");

      // push to domain page
    }
  }


  ///***************************************************************************
  ///                  A P I   K E Y   R E T R I E V A L
  ///***************************************************************************

  ///Retrieving API Key
  void _getAPIKeyRetrieval() {
    if (_demoMode) {
      loginFields._username = "andaa635@student.otago.ac.nz";
      loginFields._password = "andaa635";
    }

    //Kind of like a method, will do all sorts of fantastic things in the future
    //Creating the URL that'll query the database for our API Key
    String _requestAPIKeyRetrieval = "https://" +
        loginFields._domain +
        ".outreach.co.nz/api/0.2/auth/login/?username=" +
        loginFields._username +
        "&password=" +
        loginFields._password;
    print("API Key Retrieval");
    print('Creating the URL to generate API Keys via Login Details: ' +
        _requestAPIKeyRetrieval);

    ///This section is delayed until first login attempt has been done,
    /// results in invalid verification
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
      ///This parts important, we're generating 2 API Keys, this is the one
      /// from this login attempt
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
  void _getAPIKeyVerification() {
    //Next step is to verify the key, retrieve the user etc
    print('API Key Validation');
    String _requestAPIKeyVerification = "https://" +
        loginFields._domain +
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
  void _getContactsList() {
    print('Retrieving Contacts List\n');
    String _requestContactList = "https://" +
        loginFields._domain +
        ".outreach.co.nz/api/0.2/query/user?apikey=" +
        _apiKeyFields._apiKey +
        "&properties=%5B%27name_processed%27%5D&conditions=%5B%5B%27status%27,%27=%27,%27O%27%5D,%5B%27oid%27,%27%3E=%27,%27100%27%5D%5D";
//    Dart Encode doesn't convert apostrophes, it may be easier to write the query by hand, then CTRL + H all the necessary bits
//    Can we do this conversion cleanly in app?
//    %5B = "[" | %5D = "]" | %27 = "'" | %20 = " "

    print('Get Contact List URL: ' + _requestContactList);

    http.post(_requestContactList).then((response) {
      //Print the API Key, just so we can compare it to the subset String
      print("Contact List Response:");
      print(response.body);
      List<Contact> contactsList = new List();
      //Turning the json into a map
      Map<String, dynamic> contactListMap = json.decode(response.body);

      ///Load all of the json into a map
      print("Printing all contacts in Map");
      print(contactListMap['data']);
      print('\n \n');

      Map map = new Map();
      int index;
      String name = '';

      ///Load all of the json into a map
      index = 0;
      contactListMap['data'].forEach((dynamic) {
        map[index] = '$dynamic';
        name = map[index];
        name = name.substring(
            17,
            (name.length -
                1)); //Assumes we're getting {name_processed: ###} from the map request
        map[index] = name;
        index++;
      });

      String fullName;

      ///Convert the String in the map into a Contact (Turns the string into a fullName)
      int i = 0;
      while (i < map.length) {
        fullName = map[i];
        Contact contact = new Contact();
        contact.setFullName(fullName);
        contactsList.add(contact);
        i++;
      }

      ///Printing the contactList, sanity check
      print("Printing contactsList");
      i = 0;
      while (i < contactsList.length) {
        print(contactsList[i].getFullName());
        i++;
      }

      print('\n\n');
      contacts = contactsList;

//      contactsPage = new ContactsPage(contacts: contacts);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactsPage(contacts: contacts)),
      );
    });
  }

//  dynamic afterSplash(){
//    if(_attemptingAutoLogin && contactsPage != null) {
//      return contactsPage;
//    }
//    else {
//      return Scaffold(
//      resizeToAvoidBottomPadding: false,
//      body: new Container(
//        decoration: new BoxDecoration(
//          image: new DecorationImage(
//            image: new AssetImage('assets/images/login-background.jpg'),
//            fit: BoxFit.cover,
//          ),
//        ),
//        child: ModalProgressHUD(
//          child: LoginForm(
//            loginFormKey: _loginFormKey,
//            login: _login,
//            forgotPassword: _forgotPassword,
//            loginFields: loginFields,
//            validateUserName: _validateUserName,
//            validatePassword: _validatePassword,
//          ),
//          inAsyncCall: _inAsyncCall,
//
//          //additional options for loading modal
//          opacity: 0.5,
//          progressIndicator: CircularProgressIndicator(),
//        ),
//      )
//    );}
//  }

  @override
  Widget build(BuildContext context) {

//    return new SplashScreen(
//      seconds: 8,
//      navigateAfterSeconds: afterSplash(),
//      title: new Text('Welcome In SplashScreen',
//        style: new TextStyle(
//            fontWeight: FontWeight.bold,
//            fontSize: 20.0
//        ),),
//      image: new Image.network('https://flutter.io/images/catalog-widget-placeholder.png'),
//      backgroundColor: Colors.white,
//      styleTextUnderTheLoader: new TextStyle(),
//      photoSize: 100.0,
//      onClick: ()=>print("Flutter Egypt"),
//      loaderColor: Colors.red,
//    );

    //Build the scaffold of the page
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new LoginForm(
          loginFormKey: _loginFormKey,
          login: _login,
          forgotPassword: _forgotPassword,
          loginFields: loginFields,
          validateUserName: _validateUserName,
          validatePassword: _validatePassword,
        ),
    );
  }
}

//class AfterSplash extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//
//    if(_LoginPageState._attemptingAutoLogin){
//
//    }
//
//    return new Scaffold(
//      appBar: new AppBar(
//        title: new Text("Welcome In SplashScreen Package"),
//        automaticallyImplyLeading: false,
//      ),
//      body: new Center(
//        child: new Text("Succeeded!",
//          style: new TextStyle(
//              fontWeight: FontWeight.bold,
//              fontSize: 30.0
//          ),),
//
//      ),
//    );
//  }
//}

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> loginFormKey;
  final LoginFields loginFields;
  final Function validateUserName;
  final Function validatePassword;
  final Function login;
  final Function forgotPassword;
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  LoginForm({
    @required this.loginFormKey,
    @required this.login,
    @required this.forgotPassword,
    @required this.loginFields,
    @required this.validateUserName,
    @required this.validatePassword,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final color = const Color(0xFF0085CA);
    final theme = Theme.of(context);
    //final String url = 'https://' + loginFields._domain + '.outreach.co.nz/?Na=forgot-password-public';
    //Build the form and attach to the scaffold
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body:  new ModalProgressHUD(
          child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
              image: new AssetImage('assets/images/login-background.jpg'),
              fit: BoxFit.cover,
              ),
            ),
          child: Form(
          key: this.loginFormKey,
            child: new ListView(
              children: [
                new Container(
                    margin: const EdgeInsets.only(top: 40.0),
                    child: new Image.asset(
                      'assets/images/OutreachCRM_vert_logo.png',
                      width: 200.0,
                      height: 200.0,
                    )
                ),
                new Theme( // this colors the underline
                data: theme.copyWith(
                    primaryColor: Colors.white,
                    hintColor: Colors.white,
                    ),
                  child: new Padding(
                    padding: const EdgeInsets.fromLTRB(32.0, 40.0, 32.0, 4.0),
                    child: TextFormField(
                      key: Key('username'),
                      keyboardType: TextInputType.text,
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: new TextStyle(
                            color: Colors.white,
                            fontSize: 16.0)),
                      style: TextStyle(fontSize: 20.0, color: textTheme.button.color),
                      validator: validateUserName,
                      onSaved: (val) => this.loginFields._username = val),
                  ),
                ),
                new Theme(
                data: theme.copyWith(
                  primaryColor: Colors.white,
                  hintColor: Colors.white,
                  ),
                  child: new Padding(
                    padding: const EdgeInsets.fromLTRB(32.0, 4.0, 32.0, 32.0),
                    child: TextFormField(
                      key: Key('password'),
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      controller: passwordController,
                      decoration: InputDecoration(

                          labelText: 'Password',
                          labelStyle: new TextStyle(
                              color: Colors.white,
                              fontSize: 16.0)),
                      style: TextStyle(fontSize: 20.0, color: textTheme.button.color),
                      validator: validatePassword,
                      onSaved: (val) => this.loginFields._password = val,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(30.0),
                    shadowColor: Colors.lightBlueAccent.shade100,
                    elevation: 5.0,
                    color: color,
                    child: MaterialButton(
                      minWidth: 320.0,
                      height: 42.00,
                      onPressed: () {
                        login();
                        /// change color here to show its been pressed
                      },
                      child: Text('LOGIN',
                          style: TextStyle(fontSize: 17.0, color: Colors.white)),
                    ),
                  ),
                ),
                FlatButton(
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(fontSize: 14.0, color: Colors.white),
                  ),
                  onPressed: forgotPassword,
                ),
              ],
            ),
          ),
        ),
          inAsyncCall: _LoginPageState._inAsyncCall,

          //additional options for loading modal
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
      ),
    );
  }
}

///***************************************************************************
///                     S U P P O R T   C L A S S E S
///***************************************************************************

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
  String nameProcessed;

  //Constructor
  ContactListData({this.nameProcessed});

  //Getter method
  String getNameProcessed() {
    return nameProcessed;
  }

  //Soft of like a method that'll be executed somewhere
  factory ContactListData.fromJson(Map<String, dynamic> json) {
    return ContactListData(nameProcessed: json['name_processed']);
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
