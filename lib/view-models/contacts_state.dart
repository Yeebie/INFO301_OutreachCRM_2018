import 'package:outreach/api/contact.dart';
import 'package:outreach/models/contact.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/views/contacts_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Contacts extends StatefulWidget {
  final User user;
  Contacts(this.user);

  @override
  ContactsView createState() => new ContactsView();
}

abstract class ContactsState extends State<Contacts> 
                                        with ContactAPI{

  @protected
  String currentLetter = "";
  List<Contact> contactList = new List();
  bool hasMoreContacts = true;
  int page = 0;

  @override
  void initState(){
    super.initState();

    getContactList(page);
  }

  @protected
  void getContactList(int page) async {
    try{
      print("REQUESTING CONTACTS");
      var newData = await getContacts(widget.user, page);
      currentLetter = "";
      setState(() {
        contactList.addAll(newData);
        // tell the list we have new items
      });
    } on Exception catch(e) {
      print(e.toString().toUpperCase());
      setState(() {
        hasMoreContacts = false;
      });
    }

    print(widget.user.toMap().toString());
  }
}