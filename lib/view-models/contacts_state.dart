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
  bool fetchingInitialContacts = true;
  int page = 0;
  final CacheUtil _cache = new CacheUtil();
  User user;

  var contactWidgetList = new List<Widget>();
  var contactMap = new Map<String, List<Contact>>();

  void buildContactMap(List<Contact> contacts){

    // loop over all returned contacts
    // add them to corresponding list header
    for(final contact in contacts){

      // the key is the letter at position 0
      var key = contact.name[0].toUpperCase();

      // put new list in if absent
      contactMap.putIfAbsent(key, () => new List<Contact>());
      // add the contact to the list under that key
      contactMap[key].add(contact);

      // _contactMap.update(key, (List<Contact> val) => val.add(contact));
    }
  }


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

      buildContactMap(newData);

      currentLetter = "";


      await Future.delayed(Duration(seconds: 1));
      setState(() {
        fetchingInitialContacts = false;
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