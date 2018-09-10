import 'package:flutter/material.dart';
//import 'package:outreachcrm_app/contact_data.dart';
import 'package:outreachcrm_app/Contact.dart';

class ContactsPage extends StatefulWidget {
  Widget appBarTitle = new Text("Contacts");
  Icon actionIcon = new Icon(Icons.search);

  List<Contact> contacts;
  ContactsPage({Key key, this.contacts}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _ContactPage(contacts);
  }
}

class _ContactPage extends State<ContactsPage> {
  //Datafields
  List<Contact> kContacts;

  //Constructor
  _ContactPage(List<Contact> kContacts) {
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
          body: new ContactList(kContacts)
      ),
    );
  }
}

///Not sure if this is redundant code, is this called at all? - J.Yee
//class ContactPage extends StatelessWidget {
//  //Datafields
//  List<Contact> kContacts;
//
//  //Constructor
//  _ContactPage(List<Contact> kContacts) {
//    this.kContacts = kContacts;
//  }
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//        appBar: new AppBar(
//          title: new Text("Contacts"),
//        ),
//        ///Used to be called kContacts
//        body: new ContactList(kContacts));
//  }
//}

class ContactList extends StatelessWidget {
  final List<Contact> _contacts;

  ContactList(this._contacts);

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      padding: new EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        return new _ContactListItem(_contacts[index]);
      },
      itemCount: _contacts.length,
    );
  }
}

class _ContactListItem extends ListTile {
  _ContactListItem(Contact contact)
      : super(
            title: new Text("${contact.fullName}"),
            leading: new CircleAvatar(child: new Text(contact.fullName[0])));
}
