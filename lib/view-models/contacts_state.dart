import 'package:outreach/api/contact.dart';
import 'package:outreach/models/contact.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/util/cache_util.dart';
import 'package:outreach/util/helpers.dart';
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
  bool hasMoreContacts = true;
  bool fetchingInitialContacts = true;
  bool recentsRequested = false;
  int page = 0;
  final CacheUtil _cache = new CacheUtil();
  User user;

  var contactWidgetList = new List<Widget>();
  var contactMap = new Map<String, List<Contact>>();

  /// takes a list of contact instances and adds them
  /// to a map with the header stored as the key
  /// and the list as the paired value
  void _updateContactMap(List<Contact> contacts){

    // loop over all returned contacts
    // add them to corresponding list header
    for(final contact in contacts){
      // the key is the letter at position 0
      var key = contact.name[0].toUpperCase();

      if(!recentsRequested) key = "RECENTS";

      // put new list in if absent
      contactMap.putIfAbsent(key, () => new List<Contact>());
      // add the contact to the list under that key
      contactMap[key].add(contact);
    }
  }


  @override
  void initState(){
    super.initState();

    getMoreContacts(page);

      
  }

  @protected
  void getMoreContacts(int page) async {
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

      // request contacts from api
      var newData = await getContacts(user, page, recentsRequested);

      // update our map with new data
      _updateContactMap(newData);

      // show loading modal for a second
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        fetchingInitialContacts = false;
        recentsRequested = true;
        // tell the state we have new items
      });
    } on Exception catch(e) {
      print(e.toString().toUpperCase());
      setState(() {
        hasMoreContacts = false;
        // tell the state we can't request anymore
      });
    }
  }
}