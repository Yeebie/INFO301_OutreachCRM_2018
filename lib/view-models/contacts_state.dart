import 'package:outreach/views/contacts_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Contacts extends StatefulWidget {
  @override
  ContactsView createState() => new ContactsView();
}

abstract class ContactsState extends State<Contacts> {
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
  }
}