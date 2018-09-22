import 'package:flutter/material.dart';
import 'package:outreachcrm_app/SupportClasses.dart';
import 'package:outreachcrm_app/viewContact.dart';

///Used to utilise REST operations
import 'package:http/http.dart' as http;

///Used for API Key Retrieval
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; //Converts Json into Map

///StatelessWidget call
class ContactsPageApp extends StatelessWidget {
  //Datafields
  String _apiKey;
  String _domain;
  List<Contact> contacts = [];

  //Constructor
  ContactsPageApp(this._apiKey, this._domain);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Contacts",
        home: _ContactsPage(_apiKey, _domain, contacts: contacts));
  }
}

///Stateful Widget Call
class _ContactsPage extends StatefulWidget {
  Widget appBarTitle = new Text("Contacts");
  Icon actionIcon = new Icon(Icons.search);

  //Datafields
  String _apiKey;
  String _domain;
  List<Contact> contacts;

  //Constructor
  _ContactsPage(this._apiKey, this._domain, {Key key, this.contacts})
      : super(key: key);

  @override
  _ContactPage createState() => new _ContactPage(_apiKey, _domain, contacts);
}

///Defines the page's structure
class _ContactPage extends State<_ContactsPage> {
  //Datafields
  String _apiKey;
  String _domain;
  List<Contact> _contacts;
  ScrollController controller;
  int count;

  //Constructor
  _ContactPage(String apiKey, String domain, List<Contact> kContacts) {
    this._apiKey = apiKey;
    this._domain = domain;
    this._contacts = kContacts;
  }

  ///The list that holds all the contacts onscreen
  Widget _buildContacts() {
    print("buildContacts() empty list check");
    print("Checking if _contacts has any data");
    print("_contacts length: " + (_contacts.length).toString());

    ///The list starts with no data in it, since the getContactsList() method is in this class, we have to load it here
    if (_contacts.length == 0) {
      print("_contacts is empty, requesting resupply");
      print("\n\n");
      getContactsList(0, _apiKey, _domain);
    }

    ///As soon as the getContactsList() setState is called, this code runs the if statement again
    else if (_contacts.length != 0) {
      print("_contacts has data, displaying list");
      print("Amount of Contacts from API Request: " + count.toString());
      print("\n\n");
      return ListView.builder(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        itemBuilder: (context, index) {
          //If we hit the end of the client's contacts list, the app'll spam getContactsList()
          //This is due to the List staying at the max index and triggering the call over and over
          //count tracks the size of the last API call, you get the point
          if (index >= (_contacts.length - 1) && count != 0) {
            print("Pagination get!");
            print("\n");
            getContactsList(index, _apiKey, _domain);
          }
          return GestureDetector(
            onTap: () {
              String _oid = (_contacts[index].getOid());
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      new viewContact(_apiKey, _domain, _oid)));
            },
            child: buildRow(_contacts[index]),
          );
        },
        itemCount: _contacts.length,
      );
    }
  }

  ///Stylised contact item
  Widget buildRow(Contact contact) {
    return ListTile(
      title: new Text("${contact.fullName}"),
      leading: new CircleAvatar(
        child: new Text(contact.fullName[0]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF0085CA);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
          appBar: new AppBar(
            title: widget.appBarTitle,
            backgroundColor: color,
            actions: <Widget>[
              new IconButton(
                icon: widget.actionIcon,
                onPressed: () {
                  setState(() {
                    if (widget.actionIcon.icon == Icons.search) {
                      widget.actionIcon = new Icon(Icons.close);
                      widget.appBarTitle = new TextField(
                        style: new TextStyle(
                          color: Colors.white,
                        ),
                        decoration: new InputDecoration(
                            prefixIcon:
                                new Icon(Icons.search, color: Colors.white),
                            hintText: "Search...",
                            hintStyle: new TextStyle(color: Colors.white)),
                        onChanged: (value) {
                          print(value);
                          //filter your contact list based on value
                        },
                      );
                    } else {
                      widget.actionIcon =
                          new Icon(Icons.search); //reset to initial state
                      widget.appBarTitle = new Text("Contacts");
                    }
                  });
                },
              ),
            ],
          ),

          ///Used to be called kContacts
          body: _buildContacts()),
    );
  }

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
      print("\n");

      ///Creates a new contact filled with data, adds it to List<Contact>
      for (ContactListData data in contactListJson.data) {
        Contact contact = new Contact();
        contact.setFullName(data.getNameProcessed());
        contact.setOid(data.getOid());
        contact.setCompany(data.getCompany());
        contactsList.add(contact);
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
  }
}
