import 'package:flutter/material.dart';
import 'package:outreachcrm_app/SupportClasses.dart';

///Used to utilise REST operations
import 'package:http/http.dart' as http;

///Used for API Key Retrieval
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; //Converts Json into Map

///Stateless Widget Call
class ContactsPage extends StatefulWidget {
  Widget appBarTitle = new Text("Contacts");
  Icon actionIcon = new Icon(Icons.search);

  //Datafields
  String _apiKey;
  String _domain;
  List<Contact> contacts;

  //Constructor
  ContactsPage(this._apiKey, this._domain, {Key key, this.contacts})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _ContactPage(_apiKey, _domain, contacts);
  }
}

///Defines the page's structure
class _ContactPage extends State<ContactsPage> {
  //Datafields
  String _apiKey;
  String _domain;
  List<Contact> kContacts;
  ScrollController controller;
  List<String> items = new List.generate(100, (index) => 'Hello $index');

  //Constructor
  _ContactPage(String apiKey, String domain, List<Contact> kContacts) {
    this._apiKey = apiKey;
    this._domain = domain;
    this.kContacts = kContacts;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: widget.appBarTitle,
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
          body: new ContactList(_apiKey, _domain, kContacts)),
    );
  }
}

///Defines the item that'll pop up in the list
class ContactList extends StatelessWidget {
  //Datafields
  String _apiKey;
  String _domain;
  int _index;
  List<Contact> _contacts;
  List<Contact> contactsList = new List();

  //Constructor
  ContactList(String apiKey, String domain, List<Contact> kContacts) {
    this._apiKey = apiKey;
    this._domain = domain;
    this._contacts = kContacts;
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      padding: new EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        if (index >= (_contacts.length - 1)) {
          print("Pagination get!");
          print("Thank you " + _contacts[index].getFullName() + "!");
          _getContactsList(index);
//        _contacts.addAll(_getContactsList(index));
        } else {
          print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
          print(index);
          print(_contacts.length);
        }
        return _ContactListItem(_contacts[index]);
      },
      itemCount: _contacts.length,
    );
  }

  ///A modified ContactsListRetrieval

  ///***************************************************************************
  ///             C O N T A C T S   L I S T   R E T R I E V A L
  ///***************************************************************************

  ///Loading the Contacts List into a Collection
  List<Contact> _getContactsList(int index) {
    int _indexPagination = index;
    print("Index toString");
    print(_indexPagination);
    print(_indexPagination.toString());

    print('Retrieving Contacts List\n');

    ///Specify the API Query here, type it according to the API Specification, the app'll convert it to encoded HTML
    String apikey = "?apikey=" + _apiKey;
    String properties = "&properties=" + "['name_processed']";
    String conditions =
        "&conditions=" + "[['status','=','O'],['oid','>=','100']]";
    String order = "&order=" +
        "[['o_first_name','=','DESC'],['o_last_name','=','DESC']]"; //[[Primary sort],[Secondary sort]], used to sort people with the same first or last name so its alphabetical
    String limit = "&limit=" +
        "[24," +
        _indexPagination.toString() +
        "]"; //[Load this amount of contacts at a time, Start from this index]. Loading 25 at a time, lists start with index 0, baka.

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
      contactsList.clear();
      //Turning the json into a map
      Map<String, dynamic> contactListMap = json.decode(response.body);
      print("Printing all contacts in Map");
      print(contactListMap['data']);
      print('\n \n');

      ///Load all of the json from the old map into a new map(Easier to work on indexes)
      Map map = new Map();
      int index;
      String name = '';
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

      print("What happened to index?");
      print(_indexPagination);
      print(_indexPagination.toString());

      print("widgetTest Done!");
      setContact();
    });
  }

  void setContact() {
    int i = 0;
    print("While loop hit!");
      while (i < contactsList.length && contactsList.length == 25) {

        _contacts.add(contactsList[i]);
        print(contactsList[i].getFullName());
        i++;
      }
      i = 0;
      print(_contacts.length);
      contactsList.clear();
    }
  }

///Defines how the list item'll be styled
class _ContactListItem extends ListTile {
  _ContactListItem(Contact contact)
      : super(
            title: new Text("${contact.fullName}"),
            leading: new CircleAvatar(child: new Text(contact.fullName[0])));
}
