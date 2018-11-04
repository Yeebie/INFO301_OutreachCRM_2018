import 'package:outreach/api/contact.dart';
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
  List<String> contacts = 
    [
    "Aaron",
    "David",
    "Steve",
    "David",
    "Tim",
    "Dave",
    "Greg",
    "Sarah",
    "Boris",
    "Nancy",
    "Emily",
    "Charlie",
    "Ryan",
    "Andrew",
    "Rachel",
    "Dennis",
    "Bruce",
    "Tony",
    "Trey",
    "Dianne",
    "Deano",
    "Rodger",
    "Albion",
    ];

  @override
  void initState(){
    super.initState();
    contacts.sort();

    getContactList();
  }

  @protected
  void getContactList() async {
    await getContacts(widget.user, 0);
    await getContacts(widget.user, 1);
  }
}