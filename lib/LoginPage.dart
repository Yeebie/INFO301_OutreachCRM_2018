import 'package:flutter/material.dart';
import 'package:outreachcrm_app/ContactPage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

///Used to utilise REST operations
import 'package:http/http.dart' as http;

///Used for API Key Retrieval
import 'dart:async' show Future, Timer;
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:outreachcrm_app/SupportClasses.dart';

/// used for caching
import 'package:outreachcrm_app/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _loginSuccess = false;

class LoginPage extends StatefulWidget {
  final LoginFields loginFields;
  LoginPage({@required this.loginFields});
  @override
  _LoginPageState createState() => _LoginPageState(loginFields: loginFields);
}

class LoginFields {
  String _username = '';
  String _password = '';
  String _domain = '';
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

class ContactListFields {
  String nameProcessed = '';
}

class _LoginPageState extends State<LoginPage> {
  // data fields
//  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final LoginFields loginFields;

  _LoginPageState({this.loginFields});

  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _domainFormKey = GlobalKey<FormState>();

  APIKeyFields _apiKeyFields = new APIKeyFields();
  APIKeyValidationFields _apiKeyValidationFields = new APIKeyValidationFields();

  Map<String, dynamic> apiKey;

  //triggers modal loading overlay
  static bool _inAsyncCall = false;

  /// cache login variables
  // the cache object itself
  Future<SharedPreferences> _sPrefs = SharedPreferences.getInstance();
  // boolean to lock cache check when logging in
  bool _cacheLoginSuccess = false;

  //Puts app in demo mode (If you want to switch out the mode then you have
  //change the boolean and rerun the app. If someone finds a fix that would be
  //great)
  static bool _demoMode = false;

  @override
  void initState() {
    super.initState();

    // buy us some time so the splash screen is displayed
    new Timer(new Duration(seconds: 3), () {
      // check if the user has saved details
      _checkLoggedIn();
    });

    // call this to clear cache
     _clearLoginDetails();
  }

  bool _wifiEnabled = true;

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

  void showDialogParent(String title, String content) {
    
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(title),
              content: new Text(content),
              actions: [
                new FlatButton(
                  child: const Text("Ok"),
                  onPressed: () => exit(0),
                ),
              ],
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

  void _login() async {
    var wifiEnabled = await Util.getWifiStatus();

    try {
      if (wifiEnabled) {
        if ((_loginFormKey.currentState.validate()) ||
            (_demoMode && !_loginFormKey.currentState.validate())) {
          _loginFormKey.currentState.save();

          // dismiss keyboard
          FocusScope.of(context).requestFocus(new FocusNode());

          // start the modal progress HUD
          _inAsyncCall = true;
          _loginSuccess = true;

          _getAPIKeyRetrieval();

          Future.delayed(Duration(seconds: 4), () {
            // stop the modal progress HUD
            _inAsyncCall = false;
          });
        }
      } else {
        showDialogParent("No Internet Connection",
            "Please connect to the internet to use this application.");
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
    print("Login Cache Check");
    print("Clearing Login Details from Cache");
    print("\n\n");

    Util.removeCacheItem('domain');
    Util.removeCacheItem('username');
    Util.removeCacheItem('password');
  }

  /// method to set the cache values for login details.
  void _setLoginDetails(String domain, String username, String password) {
    // check if the field is being passed null
    if (domain != "" && username != "" && password != "") {
      print("Login Cache Check");
      print("Saving Login Details into Cache");
      print("\n\n");

      Util.setString('domain', domain);
      Util.setString('username', username);
      Util.setString('password', password);
    }
  }

  /// this method checks if there are login values in the cache, if yes
  /// then verify and push to contacts; else we push to domain entry
  Future _checkLoggedIn() async {
    // instantiate shared preferences (cache)
    SharedPreferences prefs = await _sPrefs;
    var wifiEnabled = await Util.getWifiStatus();

    // attempt to read in cache values, return null if not found
    String _cachedDomain = (prefs.getString('domain') ?? null);
    String _cachedUsername = (prefs.getString('username') ?? null);
    String _cachedPassword = (prefs.getString('password') ?? null);

    if (wifiEnabled) {
      // check if the login details are in cache
      if (_cachedDomain != null &&
          _cachedUsername != null &&
          _cachedPassword != null) {
        print("Login Cache Check");
        print("Previous Login Details Found");
        print("\n\n");
        loginFields._domain = _cachedDomain;
        loginFields._username = _cachedUsername;
        loginFields._password = _cachedPassword;

        // attempt the login
        // if we are not currently trying to login
        if (_cacheLoginSuccess == false) {
          // attempt to get API key
          _getAPIKeyRetrieval();
          _cacheLoginSuccess = true;
        }
      } else {
        // else you found nothing, redirect to login

        print("Login Cache Check");
        print("No Login Details Found");
        print("\n\n");

        // push to domain page
        // pass all the details the login form needs too
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new DomainForm(
                      domainFormKey: _domainFormKey,
                      loginFormKey: _loginFormKey,
                      login: _login,
                      forgotPassword: _forgotPassword,
                      loginFields: loginFields,
                      validateUserName: _validateUserName,
                      validatePassword: _validatePassword,
                    )));
      }
    } else {
      showDialogParent("No Internet Connection",
          "Please connect to the internet to use this application.");
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
        _loginSuccess = false;
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

        /// Set the login cache with the validated fields
        _setLoginDetails(
            loginFields._domain, loginFields._username, loginFields._password);

        _getContactPage();
      } else {
        showDialogParent("Incorrect API Key.", "API Key isn't valid.");
        _loginSuccess = false;
      }
    });
  }

  ///***************************************************************************
  ///                   C O N T A C T S   P A G E   C A L L
  ///***************************************************************************

  /// pushing to contact page
  void _getContactPage() {
    ///Send the contactsList to be displayed on the ContactsPage
    usernameController.clear();
    passwordController.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ContactsPageApp(_apiKeyFields._apiKey,
              loginFields._domain, loginFields._username)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // this is the splash screen
    return new ModalProgressHUD(
      child: Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage('assets/images/background-image.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      inAsyncCall: true,
    );
  }
}

///***************************************************************************
///                   D O M A I N  P A G E  B U I L D
///***************************************************************************

class DomainForm extends StatefulWidget {
  // fields required for domain form
  final LoginFields loginFields;
  final GlobalKey<FormState> domainFormKey;
  // fields required for login form
  final GlobalKey<FormState> loginFormKey;
  final Function validateUserName;
  final Function validatePassword;
  final Function login;
  final Function forgotPassword;

  DomainForm({
    @required this.domainFormKey,
    @required this.loginFormKey,
    @required this.login,
    @required this.forgotPassword,
    @required this.loginFields,
    @required this.validateUserName,
    @required this.validatePassword,
  });

  @override
  DomainFormState createState() {
    return DomainFormState(
      domainFormKey: domainFormKey,
      loginFormKey: loginFormKey,
      login: login,
      forgotPassword: forgotPassword,
      loginFields: loginFields,
      validateUserName: validateUserName,
      validatePassword: validatePassword,
    );
  }
}

class DomainFormState extends State<DomainForm> {
  final GlobalKey<FormState> domainFormKey;
  final GlobalKey<FormState> loginFormKey;
  final LoginFields loginFields;
  final Function validateUserName;
  final Function validatePassword;
  final Function login;
  final Function forgotPassword;
  final TextEditingController domainController = new TextEditingController();

  RegExp domainPattern = new RegExp(
    r"^[a-zA-Z0-9]*$",
    caseSensitive: false,
    multiLine: false,
  );

  DomainFormState({
    @required this.domainFormKey,
    @required this.loginFormKey,
    @required this.login,
    @required this.forgotPassword,
    @required this.loginFields,
    @required this.validateUserName,
    @required this.validatePassword,
  });

  //Shows dialogue for the back button on Androids
  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Do you want to exit?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("No"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(child: Text("Yes"), onPressed: () => exit(0)),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final color = const Color(0xFF0085CA);
    final theme = Theme.of(context);

    //Build the form and attach to the scaffold
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('assets/images/background-image.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Form(
              key: this.domainFormKey,
              child: new ListView(
                children: [
                  new Container(
                      margin: const EdgeInsets.only(top: 40.0),
                      child: new Image.asset(
                        'assets/images/OutreachCRM_vert_logo.png',
                        height: MediaQuery.of(context).size.height/4,
                        width: MediaQuery.of(context).size.width/4,
                      )),
                  new Theme(
                    // this colors the underline
                    data: theme.copyWith(
                      primaryColor: Colors.white,
                      hintColor: Colors.white,
                    ),
                    child: new Padding(
                      padding: const EdgeInsets.fromLTRB(32.0, 40.0, 32.0, 4.0),
                      child: TextFormField(
                          key: Key('domain'),
                          keyboardType: TextInputType.text,
                          controller: domainController,
                          decoration: InputDecoration(
                              fillColor: Colors.black.withOpacity(0.6),
                              filled: true,
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(8.0),
                                ),
                                borderSide: new BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ),
                              ),
                              labelText: 'Company Domain',
                              labelStyle: new TextStyle(
                                  color: Colors.white, fontSize: 16.0)),
                          style: TextStyle(fontSize: 20.0, color: Colors.white),
                          validator: (val) {
                            print("Entered Domain: " + val);
                            if (val.isEmpty) {
                              return 'Please enter some text';
                            } else if (!domainPattern.hasMatch(val)) {
                              return 'Only enter alphanumeric characters';
                            } else {
                              loginFields._domain = val;
                            }
                            print("Done the Domain Check If Statements");
                          },
                          onSaved: (val) => this.loginFields._domain = val),
                    ),
                  ),
                  new Theme(
                    data: theme.copyWith(
                      primaryColor: Colors.white,
                      hintColor: Colors.white,
                    ),
                    child: new Padding(
                      padding: const EdgeInsets.fromLTRB(32.0, 4.0, 32.0, 32.0),
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
                          if (domainFormKey.currentState.validate()) {
                            print(
                                "Internal Validator check complete, code isn't malicious");
                            _getDomainValidation(loginFields._domain);
                          }
                        },
                        child: Text(
                          'NEXT',
                          style: TextStyle(fontSize: 17.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  FlatButton(
                    child: Text(
                      "What is a domain?",
                      style: TextStyle(fontSize: 14.0, color: Colors.grey),
                    ),
                    onPressed: forgotPassword,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  ///***************************************************************************
  ///                  D O M A I N   V A L I D A T I O N
  ///***************************************************************************

  ///Retrieving API Key
  void _getDomainValidation(String domain) async {
    bool _isDomain = false;
    //Creating the URL that'll query the database for our API Key
    String _requestDomainValidation = "https://" + domain + ".outreach.co.nz";
    print('Creating the URL to check if current Domain is valid: ' +
        _requestDomainValidation);

    await http.get(_requestDomainValidation).then((response) {
      //Print the API Key, just so we can compare it to the final result
      print("Original Response body: ${response.statusCode}");

      print("Checking if domain is valid");
      if (response.statusCode.toString() == "404") {
        _isDomain = false;
        print(domain + " is not a valid domain");
      } else {
        print(domain + " is a valid domain");
        _isDomain = true;
      }
      print("Printing _isDomain");
      print(_isDomain);
      print("Domain is valid, sending to LoginPage");
      print("\n\n");

      if (_isDomain == false) {
        showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  title: Text("Domain does not exist"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Okay"),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ));
      } else {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) =>
                new LoginForm(
                  loginFormKey: loginFormKey,
                  login: login,
                  forgotPassword: forgotPassword,
                  loginFields: loginFields,
                  validateUserName: validateUserName,
                  validatePassword: validatePassword,
                )
            )
        );
      }

      ///Old Validator code was here
    });
  }
}

///***************************************************************************
///                   L O G I N   P A G E   B U I L D
///***************************************************************************

class LoginForm extends StatefulWidget {
  final GlobalKey<FormState> loginFormKey;
  final LoginFields loginFields;
  final Function validateUserName;
  final Function validatePassword;
  final Function login;
  final Function forgotPassword;

  LoginForm({
    @required this.loginFormKey,
    @required this.login,
    @required this.forgotPassword,
    @required this.loginFields,
    @required this.validateUserName,
    @required this.validatePassword,
  });

  @override
  LoginFormState createState() {
    return LoginFormState(
      loginFormKey: loginFormKey,
      login: login,
      forgotPassword: forgotPassword,
      loginFields: loginFields,
      validateUserName: validateUserName,
      validatePassword: validatePassword,
    );
  }
}

class LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> loginFormKey;
  final LoginFields loginFields;
  final Function validateUserName;
  final Function validatePassword;
  final Function login;
  final Function forgotPassword;
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  LoginFormState({
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

    //These statements might be unncessary. Not sure.
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);


    //Build the form and attach to the scaffold
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new ModalProgressHUD(
        child: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/background-image.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: this.loginFormKey,
            child: new ListView(
              children: [
                new Container(

                    margin: const EdgeInsets.only(top: 30.0),
                    child: new Image.asset(
                      'assets/images/OutreachCRM_vert_logo.png',
                      height: MediaQuery.of(context).size.height/5,
                      width: MediaQuery.of(context).size.width/5,
//                      queryData.size.width
  //                    queryData.size.height
    //                  width: 150.0,
      //                height: 150.0,
                    )),
                new Theme(
                  // this colors the underline
                  data: theme.copyWith(
                    primaryColor: Colors.white,
                    hintColor: Colors.transparent,
                  ),
                  child: new Padding(
                    padding: const EdgeInsets.fromLTRB(32.0, 40.0, 32.0, 4.0),
                    child: TextFormField(
                        key: Key('username'),
                        keyboardType: TextInputType.text,
                        controller: usernameController,
                        decoration: InputDecoration(
                            fillColor: Colors.black.withOpacity(0.6),
                            filled: true,
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(8.0),
                              ),
                              borderSide: new BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                            ),
                            labelText: 'Username',
                            labelStyle: new TextStyle(
                                color: Colors.white, fontSize: 16.0)),
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                        validator: validateUserName,
                        onSaved: (val) => this.loginFields._username = val),
                  ),
                ),
                new Theme(
                  data: theme.copyWith(
                    primaryColor: Colors.white,
                    hintColor: Colors.transparent,
                  ),
                  child: new Padding(
                    padding: const EdgeInsets.fromLTRB(32.0, 4.0, 32.0, 32.0),
                    child: TextFormField(
                      key: Key('password'),
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      controller: passwordController,
//                      onEditingComplete: () {
//                        loginFormKey.currentState.save();
//                      },
                      decoration: InputDecoration(
                          fillColor: Colors.black.withOpacity(0.6),
                          filled: true,
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(8.0),
                            ),
                            borderSide: new BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                          ),
                          labelText: 'Password',
                          labelStyle: new TextStyle(
                              color: Colors.white, fontSize: 16.0)),
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
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
                    color: _loginSuccess ? Colors.grey : color,
                    child: MaterialButton(
                      minWidth: 320.0,
                      height: 42.00,
                      onPressed: () {
                        setState(() {
                          _loginSuccess ? print("login disabled") : login();
                        });

                        Future.delayed(Duration(seconds: 4), () {
                          setState(() {});
                        });
                      },
                      child: Text('LOGIN',
                          style:
                              TextStyle(fontSize: 17.0, color: Colors.white)),
                    ),
                  ),
                ),
                FlatButton(
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
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
