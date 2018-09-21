import 'package:flutter/material.dart';
import 'package:outreachcrm_app/ContactPage.dart';
import 'package:validate/validate.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

///Used to utilise REST operations
import 'package:http/http.dart' as http;

///Used for API Key Retrieval
import 'dart:async' show Future, Timer;
import 'dart:convert'; //Converts Json into Map

import 'package:outreachcrm_app/SupportClasses.dart';
import 'package:splashscreen/splashscreen.dart';

/// used for caching
import 'package:outreachcrm_app/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(new MyApp());
  print("\n");
  print("Outreach: Flutter Application");
  print("Branch:   Master");
  print(
      "Build:    Sprint 3 Release | Post-UI & Cache Overhaul, Local ContactPage Rewrite, SupportClasses addition");
  print("Task:     Manually merge Master & UI_Pagination");
  print("\n");
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return new MaterialApp(
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
  String _cacheDomain, _cacheUsername, _cachePassword;
  // boolean to lock cache check when logging in
  bool _attemptingAutoLogin = false;

  //Datafields
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

  AnimationController _iconAnimationController;
  Animation<double> _iconAnimation;

  //triggers modal loading overlay
  bool _inAsyncCall = false;
  //Puts app in demo mode (If you want to switch out the mode then you have
  //change the boolean and rerun the app. If someone finds a fix that would be
  //great)
  bool _demoMode = false;
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

  bool _wifiEnabled = true;

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

          /// Set the login cache with the validated fields
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
    _cachePassword = null;
    _cacheUsername = null;
    _cacheDomain = null;

    Util.removeCacheItem('domain');
    Util.removeCacheItem('username');
    Util.removeCacheItem('password');
  }

  /// method to get login details from cache and store them in local variables
  Future _getLoginDetails() async {
    final SharedPreferences prefs = await _sPrefs;

    _cacheDomain = prefs.getString('domain') ?? null;
    _cacheUsername = prefs.getString('username') ?? null;
    _cachePassword = prefs.getString('password') ?? null;
  }

  /// method to set the cache values for login details.
  void _setLoginDetails(String domain, String username, String password){

    print("----------------------------------");
    print("caching deets my dude");
    print("----------------------------------");

    if(domain != "" && username != ""
        && password != "") {
      Util.setString('domain', domain);
      Util.setString('username', username);
      Util.setString('password', password);
    }
  }

  /// method checks if there are login values in cache.
  /// if yes; update the class variables with cached data
  /// and return true.
  bool _userHasLoggedIn() {
    if(_cacheDomain != null &&_cacheUsername != null
        && _cachePassword != null) {

      print("----------------------------------");
      print("details were in cache my dude");
      print("----------------------------------");

      loginFields._domain = _cacheDomain;
      loginFields._username = _cacheUsername;
      loginFields._password = _cachePassword;

      return true;
    }
    return false;
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
        loginFields._domain +
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
            builder: (context) => ContactsPageApp(
                _apiKeyFields._apiKey, loginFields._domain,
                contacts: contactsList)),
      );
    });
  }
  dynamic afterSplash(){
    if(_attemptingAutoLogin) {
      return null;
    }
    else {
      return Scaffold(
          resizeToAvoidBottomPadding: false,
          body: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('assets/images/login-background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: ModalProgressHUD(
              child: LoginForm(
                loginFormKey: _loginFormKey,
                login: _login,
                forgotPassword: _forgotPassword,
                loginFields: loginFields,
                validateUserName: _validateUserName,
                validatePassword: _validatePassword,
              ),
              inAsyncCall: _inAsyncCall,

              //additional options for loading modal
              opacity: 0.5,
              progressIndicator: CircularProgressIndicator(),
            ),
          )
      );}
  }

  @override
  Widget build(BuildContext context) {

    /// call this to clear cache
//    _clearLoginDetails();

    /// if we are not currently trying to login
    if(_attemptingAutoLogin == false) {
      /// attempt to retrieve details from cache
      _getLoginDetails();
      /// if the user has logged in before, attempt to get new API key
      if (_userHasLoggedIn()) {
        print("------------------------------------");
        print(_cacheDomain);
        print(_cacheUsername);
        print(_cachePassword);
        print("------------------------------------");

        _getAPIKeyRetrieval();
//        _login();
        _attemptingAutoLogin = true;
      }
    }
//    return new SplashScreen(
//      seconds: 5,
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
        body: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/login-background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ModalProgressHUD(
            child: LoginForm(
              loginFormKey: _loginFormKey,
              login: _login,
              forgotPassword: _forgotPassword,
              loginFields: loginFields,
              validateUserName: _validateUserName,
              validatePassword: _validatePassword,
            ),
            inAsyncCall: _inAsyncCall,

            //additional options for loading modal
            opacity: 0.5,
            progressIndicator: CircularProgressIndicator(),
          ),
        )
    );
  }
}

class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Welcome In SplashScreen Package"),
        automaticallyImplyLeading: false,
      ),
      body: new Center(
        child: new Text("Succeeded!",
          style: new TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0
          ),),

      ),
    );
  }
}

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
    return Form(
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
    );
  }
}

