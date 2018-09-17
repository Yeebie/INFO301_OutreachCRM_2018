import 'package:flutter/material.dart';
import 'package:outreachcrm_app/SupportClasses.dart';

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
  List<Contact> contacts;

  //Constructor
  ContactsPageApp(this._apiKey, this._domain, {Key key, this.contacts})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  //Constructor
  _ContactPage(String apiKey, String domain, List<Contact> kContacts) {
    this._apiKey = apiKey;
    this._domain = domain;
    this._contacts = kContacts;
  }

  void getData(index) {
//      setState(() { ///setState called during build
        getContactsList(index, _apiKey, _domain);
//      });
  }

  ///List that shows contacts
  Widget _buildContacts() {
    return ListView.builder(
      padding: new EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        if (index >= (_contacts.length - 1)) {
          print("\n");
          print("Pagination get!");
          print("\n\n");
            getData(index);
        }
        return buildRow(_contacts[index]);
      },
      itemCount: _contacts.length,
    );
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
          body: _buildContacts()),
    );
  }

  ///Loading the Contacts List into a Collection
  Future<Contact> getContactsList(int index, String _apiKey, String _domain) async {
    int _indexPagination = index;
    print('Retrieving Contacts List');

    ///Specify the API Query here, type it according to the API Specification, the app'll convert it to encoded HTML
    String apikey = "?apikey=" + _apiKey;
    String properties = "&properties=" + "['name_processed','oid','o_company']";
    String conditions =
        "&conditions=" + "[['status','=','O'],['oid','>=','100']]";
    String order = "&order=" +
        "[['o_first_name','=','DESC'],['o_last_name','=','DESC']]"; //[[Primary sort],[Secondary sort]], used to sort people with the same first or last name so its alphabetical
    String limit = "&limit=" +
        "[24," +
        (_indexPagination + 1).toString() +
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
      while (i < contactsList.length && contactsList.length == 25) {
        print(contactsList[i].getFullName());
        i++;
      }
      print("\n");
//      return contactsList;
      _contacts.addAll(contactsList);
    });
  }
}
