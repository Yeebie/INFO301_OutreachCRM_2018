import 'package:flutter/material.dart';
import 'package:outreach/SupportClasses.dart';
import 'dart:io';
import 'package:outreach/ViewContact.dart';
import 'package:outreach/util.dart';

///Used to utilise REST operations
import 'package:http/http.dart' as http;

///Used for API Key Retrieval
import 'dart:async' show Future;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart'; //Converts Json into Map


/// method used for clearing the cache variables and exiting the app
void clearLoginDetails() async{
  print("-------------------------");
  print("CLEARING DETAILS IN CACHE");
  print("-------------------------");
  await Util.removeCacheItem('domain');
  await Util.removeCacheItem('username');
  await Util.removeCacheItem('password');
  print("-------------------------");
  print("EXITING THE APP");
  print("-------------------------");
  exit(0);
}

///StatelessWidget call
class ContactsPageApp extends StatelessWidget {
  //Data fields
  String _apiKey;
  String _domain;
  String _username;
  List<Contact> contacts = [];

  //Constructor
  ContactsPageApp(this._apiKey, this._domain, this._username);

  ///wipes cache of user details, prevents future auto logins
  void deleteAPIKey() {
    //Purge ourselves of that pesky APIKey
    String apikey = "?apikey=" + _apiKey;
    String _requestAPIKeyRemoval =
        "https://" + _domain + ".outreach.co.nz/api/0.2/auth/logout/" + apikey;

    http.post(_requestAPIKeyRemoval).then((response) {
      //Print the API Key, just so we can compare it to the final result
      print("API Key Delete Check: ${response.body}");
     
      print("-------------------------");
      print("CALLING CLEAR LOGIN DETAILS");
      print("-------------------------");
      // clear cache and exit app
      clearLoginDetails();
    });
      
    
  }

  @override
  Widget build(BuildContext context) {
    //Shows dialogue for the back button on Androids
    Future<bool> _onBackPressed() {
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                    "Are you sure you want to log out of your account and close the application?"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("No"),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  FlatButton(
                      child: Text("Yes"),
                      onPressed: () {
                        deleteAPIKey();
                      })
                ],
              ));
    }

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Contacts",
            home: _ContactsPage(_apiKey, _domain, _username,
                contacts: contacts)));
  }
}


///***************************************************************************
///                 C O N T A C T  P A G E  D E F I N I T I O N
///***************************************************************************


///Stateful Widget Call
class _ContactsPage extends StatefulWidget {
  Widget appBarTitle = new Text("Contacts");
  Icon actionIcon = new Icon(Icons.search);

  //Data fields
  String _apiKey;
  String _domain;
  String _username;
  List<Contact> contacts;
  List<Contact> recentContacts;
  bool finishedSearching;

  //Constructor
  _ContactsPage(this._apiKey, this._domain, this._username,
      {Key key, this.contacts})
      : super(key: key);

  @override
  _ContactPage createState() =>
      new _ContactPage(_apiKey, _domain, _username, contacts);
}

///Defines the page's structure
class _ContactPage extends State<_ContactsPage> {
  //Data fields
  String _apiKey;
  String _domain;
  String _username;
  List<Contact> _contacts;
  List<Contact> _usernameList = [];
  List<Contact> _recentContacts;
  ScrollController controller;
  int count;
  bool _finishedSearching = false;
  bool _firstRun = true;

  RegExp searchPattern = new RegExp(
    r"^[a-zA-Z0-9 ]*$",
    caseSensitive: false,
    multiLine: false,
  );

  Contact contact = new Contact();
  String name_processed = " ";

  //Data fields for the app bar
  final formKey = new GlobalKey<FormState>();
  final key = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _filter = new TextEditingController();
  final color = const Color(0xFF0085CA);
  final white = const Color(0xFFFFFFFF);
  Icon _searchIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget _appBarTitle = new Text('Contacts');

  //Constructor
  _ContactPage(
      this._apiKey, this._domain, this._username, List<Contact> kContacts) {
    this._contacts = kContacts;
    this._recentContacts = kContacts;
  }

  ///The list that holds all the contacts onscreen
  Widget _buildContacts() {
    bool searching;
    //Checks to see if we are in searching mode or not
    if (this._searchIcon.icon == Icons.close) {
      searching = true;
    } else {
      searching = false;
    }
    print("buildContacts() empty list check");
    print("Checking if _contacts has any data");
    print("_contacts length: " + (_contacts.length).toString());

    //Once we're finished searching I just set the contacts list
    //to the 25 most recent contacts which were stored in a list
    //in the first run of the application.
    if (_finishedSearching) {
      _contacts.clear();
      _contacts = new List<Contact>.from(_recentContacts);
      _finishedSearching = false;
    }

    ///The list starts with no data in it, since the getContactsList() method is in this class, we have to load it here
    ///Added check to see if we are searching
    if (_contacts.length == 0 && !searching) {
      print("_contacts is empty, requesting resupply");
      print("\n\n");
      getContactsList(0, _apiKey, _domain);
    }

    ///As soon as the getContactsList() setState is called, this code runs the if statement again
    else if (_contacts.length != 0) {
      print("_contacts has data, displaying list");
      print("Amount of Contacts from API Request: " + count.toString());
      return ListView.builder(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        itemBuilder: (context, index) {
          //If we hit the end of the client's contacts list, the app'll spam getContactsList()
          //This is due to the List staying at the max index and triggering the call over and over
          //count tracks the size of the last API call, you get the point.

          //Added check to see if we are searching or not as we don't want to paginate if
          //we are searching and also if we've just exited searching we just want to use
          //the first 25 contacts in recent contacts.
          if (index >= (_contacts.length - 1) &&
              count != 0 &&
              !searching &&
              !_finishedSearching) {
            print("\n");
            print("Pagination get!");
            print("\n");
            getContactsList(index, _apiKey, _domain);
          }
          return GestureDetector(
            onTap: () {
              String _oid = (_contacts[index].getOid());
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      new ViewContactApp(_apiKey, _domain, _oid, _username)));
            },
            child: buildRow(_contacts[index]),
          );
        },
        itemCount: _contacts.length,
      );
    }
  }


  ///***************************************************************************
  ///                   S E A R C H  H A N D L I N G
  ///***************************************************************************


  //This method gets called when the search icon is pressed
  //It reveals a text field and allows a user to search their contacts
  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close, color: Colors.white);
        this._appBarTitle = new TextField(
          controller: _filter,
          style: new TextStyle(
            color: Colors.white,
          ),
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search, color: Colors.white),
              hintText: 'Search...',
              hintStyle: new TextStyle(color: Colors.white),
              labelStyle: new TextStyle(color: Colors.white)),
          onChanged: (value) {
           if (value.length > 0 && searchPattern.hasMatch(value) && value.length < 30) {
              searchContactsList(_apiKey, _domain, value);
            } 
          },
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Contacts');
        _filter.clear();
        // _contacts.clear();
        _finishedSearching = true;
        //getContactsList(0, _apiKey, _domain);
        //_buildContacts();
      }
    });
  }


  ///***************************************************************************
  ///                   U I   C O N S T R U C T I O N
  ///***************************************************************************


  ///Stylised contact item
  Widget buildRow(Contact contact) {
    return ListTile(
      title: new Text("${contact.fullName}"),
      leading: new CircleAvatar(
        child: new Text(contact.fullName[0]),
      ),
    );
  }

  //Method for building a custom app bar
  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _appBarTitle,
      backgroundColor: color,

      leading: new IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
        color: Colors.white,
      ),

      ///UI_Development settings cog
      actions: <Widget>[
        new IconButton(

            ///UI_Development had "icon: new IconButton(icon: new Icon(Icons.settings),". What did this do?
            icon: new Icon(Icons.settings),
            onPressed: () => _scaffoldKey.currentState.openDrawer()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF0085CA);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
          key: _scaffoldKey,
          drawer: _drawer(),
          resizeToAvoidBottomPadding: false,
          appBar: _buildBar(context),
          body: _buildContacts()),
    );
  }


  ///***************************************************************************
  ///                   D R A W E R  S E T T I N G S
  ///***************************************************************************



  ///Settings menu
  Widget _drawer() {
    void deleteAPIKey() {
      //Purge ourselves of that pesky APIKey
      String apikey = "?apikey=" + _apiKey;
      String _requestAPIKeyRemoval = "https://" +
          _domain +
          ".outreach.co.nz/api/0.2/auth/logout/" +
          apikey;

      http.post(_requestAPIKeyRemoval).then((response) {
        //Print the API Key, just so we can compare it to the final result
        print("API Key Delete Check: ${response.body}");

      print("-------------------------");
      print("CALLING CLEAR LOGIN DETAILS");
      print("-------------------------");
      clearLoginDetails();
      });
    }

    ///Fills name_processed if its empty, this statements just been slapped in here, position doesn't matter
    if (name_processed == " ") {
      getUsername(_username, _apiKey, _domain);
    }
    return Drawer(
        child: new ListView(
      children: <Widget>[
        new UserAccountsDrawerHeader(
          //////// API Request to display users name and email maybe?//////////
          accountName: new Text(name_processed),
          accountEmail: new Text(_username),
          currentAccountPicture: new CircleAvatar(
            backgroundColor: Colors.white,
            child: new Text(name_processed.substring(0, 1)),
          ),
        ),
        new ListTile(
          title: new Text("Contact Us"),
          trailing: new Icon(Icons.arrow_right),
          onTap: _launchURL,
        ),
        new ListTile(
            title: new Text("Logout"),
            trailing: new Icon(Icons.close),
            onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text(
                          "Are you sure you want to log out of your account and close the application?"),
                      actions: <Widget>[
                        FlatButton(
                            child: Text("No"),
                            onPressed: () => Navigator.pop(context, false)),
                        FlatButton(
                          child: Text("Yes"),
                          onPressed: () {
                            deleteAPIKey();
                          },
                        )
                      ],
                    ))),
        TextField(
          textAlign: TextAlign.center,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Copyright Outreach CRM 2018 © '),
        ),
      ],
    ));
  }

  _launchURL() async {
    //Launches to Outreach contact page
    const url = 'https://www.outreachcrm.co.nz/#comp-jjp7272e';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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


  ///***************************************************************************
  ///                 C O N T A C T   A P I   R E Q U E S T S
  ///***************************************************************************


  ///Loading the Contacts List into a Collection
  Future<Contact> getContactsList(
      int index, String _apiKey, String _domain) async {
    int _indexPagination;

    ///Specify the API Query here, type it according to the API Specification, the app'll convert it to encoded HTML
    String apikey = "?apikey=" + _apiKey;
    String properties = "&properties=" + "['name_processed','oid','o_company']";
    String conditions =
        "&conditions=" + "[['status','=','O'],['oid','>=','100']]";
    String order;
    if (index == 0) {
      //If there is nothing in the list, get last modified contacts starting at index 0
      _indexPagination = index;
      order = "&order=" + "[['modified','DESC']]";
    } else {
      //If there is something in the list, get contacts starting at the index that triggered the pagination + 1, minus the 25 recently modified contacts
      _indexPagination = ((index + 1) - 25);
      order = "&order=" +
          "[['o_first_name','=','DESC'],['o_last_name','=','DESC']]"; //[[Primary sort],[Secondary sort]], used to sort people with the same first or last name so its alphabetical
    }
    String limit = "&limit=" +
        "[24," +
        (_indexPagination).toString() +
        "]"; //[Load this amount of contacts at a time, Start from this index]. Loading 25 at a time, lists start with index 0, baka.

    print('Retrieving Contacts List');

    ///Specifying the URL we'll make to call the API
    String _requestContactList = "https://" +
        _domain +
        ".outreach.co.nz/api/0.2/query/user" +
        (apikey + properties + conditions + order + limit);

    var wifiEnabled = await Util.getWifiStatus();

    ///Encoding the String so its HTML safe
    _requestContactList = _requestContactList.replaceAll("[", "%5B");
    _requestContactList = _requestContactList.replaceAll("]", "%5D");
    _requestContactList = _requestContactList.replaceAll("'", "%27");
    _requestContactList = _requestContactList.replaceAll(">", "%3E");
    print('Get Contact List URL: ' + _requestContactList);

    if (wifiEnabled) {
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
        print("\n");

        ///Creates a new contact filled with data, adds it to List<Contact>
        for (ContactListData data in contactListJson.data) {
          Contact contact = new Contact();
          contact.setFullName(data.getNameProcessed());
          contact.setOid(data.getOid());
          contact.setCompany(data.getCompany());
          contactsList.add(contact);
        }

        //On the first run of the application only get the first 25
        //contacts and store them in the recentContacts list for later
        //use. No need to call the API again and fixes double list issue.
        if (_firstRun) {
          _recentContacts = new List<Contact>.from(contactsList);
          _firstRun = false;
        }

        count = contactsList.length;

        ///Printing the contactList, sanity check
        print("Printing contactsList");
        int i = 0;
        while (i < contactsList.length) {
          print(contactsList[i].getFullName());
          i++;
        }
        print("\n");

        ///Add the new contacts to the current List, refresh list
        _contacts.addAll(contactsList);
        setState(() {});
      });
    } else {
      showDialogParent("No Internet Connection",
          "Please connect to the internet to use this application.");
    }
  }

  ///This function will search the users contacts list based
  ///on the input they put in the search box.
  Future<Contact> searchContactsList(
      String _apiKey, String _domain, String query) async {
    String apikey = "?apikey=" + _apiKey;

    String properties = "&properties=" +
        "['oid','name_processed','modified']" +
        "&search=['OR',['o_first_name','like','" +
        query +
        "'],['o_last_name','like','" +
        query +
        "'],['name_processed','like','" +
        query +
        "']]&order=[['modified','DESC'],['o_first_name','=','DESC'],['o_last_name','=','DESC']]&limit=20";

    print('Retrieving Contacts List');

    ///Specifying the URL we'll make to call the API
    String _requestContactList = "https://" +
        _domain +
        ".outreach.co.nz/api/0.2/query/user" +
        (apikey + properties);

    ///Encoding the String so its HTML safe
    _requestContactList = _requestContactList.replaceAll("[", "%5B");
    _requestContactList = _requestContactList.replaceAll("]", "%5D");
    _requestContactList = _requestContactList.replaceAll("'", "%27");
    _requestContactList = _requestContactList.replaceAll(">", "%3E");
    print('Get Contact List URL: ' + _requestContactList);

    var wifiEnabled = await Util.getWifiStatus();

    if (wifiEnabled) {
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
        print("\n");

        ///Creates a new contact filled with data, adds it to List<Contact>
        for (ContactListData data in contactListJson.data) {
          Contact contact = new Contact();
          contact.setFullName(data.getNameProcessed());
          contact.setOid(data.getOid());
          contact.setCompany(data.getCompany());
          contactsList.add(contact);
        }

        _contacts.clear();
        _contacts.addAll(contactsList);
        setState(() {});
      });
    } else {
      showDialogParent("No Internet Connection",
          "Please connect to the internet to use this application.");
    }
  }

  ///Loading the Contacts List into a Collection
  Future<Contact> getUsername(
      String _username, String _apiKey, String _domain) async {
    ///Specify the API Query here, type it according to the API Specification, the app'll convert it to encoded HTML
    String apikey = "?apikey=" + _apiKey;
    String properties = "&properties=" + "['name_processed']";
    String conditions = "&conditions=" + "[['login','=','" + _username + "']]";

    ///Specifying the URL we'll make to call the API
    String _requestUsername = "https://" +
        _domain +
        ".outreach.co.nz/api/0.2/query/user" +
        (apikey + properties + conditions);

    ///Encoding the String so its HTML safe
    _requestUsername = _requestUsername.replaceAll("[", "%5B");
    _requestUsername = _requestUsername.replaceAll("]", "%5D");
    _requestUsername = _requestUsername.replaceAll("'", "%27");
    _requestUsername = _requestUsername.replaceAll(">", "%3E");

    ///Send an API request, load all of the json into a map
    http.post(_requestUsername).then((response) {
      //Print the API Key, just so we can compare it to the subset String
      List<Contact> usernameList = new List();
      //Turning the json into a map
      final usernameMap = json.decode(response.body);
      ContactListJson usernameJson = new ContactListJson.fromJson(usernameMap);
      print("\n\n");

      ///Creates a new contact filled with data, adds it to List<Contact>
      for (ContactListData data in usernameJson.data) {
        contact.setFullName(data.getNameProcessed());
        usernameList.add(contact);
      }
      name_processed = contact.getFullName();

      ///Add the new contacts to the current List, refresh list
      _usernameList.addAll(usernameList);
    });
  }
}
