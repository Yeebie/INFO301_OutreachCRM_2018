import 'package:outreach/api/contact.dart';
import 'package:outreach/models/contact.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/util/cache_util.dart';
import 'package:outreach/views/contacts_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Contacts extends StatefulWidget {
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
  final CacheUtil _cache = new CacheUtil();
  User user;

  @override
  void initState(){
    super.initState();

    updateContactList(page);
  }

  @protected
  void updateContactList(int page) async {

    // await _cache.clearAllUsers();
    // grab the user from cache
    user == null
      ? user = await _cache.getCurrentUser()
      : user = user;

    try{
      print(
        "-------------------"
        "\nREQUESTING CONTACTS"
        "\n-------------------");
      var newData = await getContacts(user, page);
      currentLetter = "";
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        contactList.addAll(newData);
        // tell the state we have new items
      });
    } on Exception catch(e) {
      print(e.toString().toUpperCase());
      setState(() {
        hasMoreContacts = false;
      });
    }
  }
}