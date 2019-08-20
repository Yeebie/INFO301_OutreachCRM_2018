import 'package:outreach/api/contact.dart';
import 'package:outreach/models/contact.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/util/cache_util.dart';
import 'package:outreach/util/helpers.dart';
import 'package:outreach/views/contacts_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/models/contacts.dart';

class Contacts extends StatefulWidget {
  Contacts({Key key}) : super(key: UniqueKey());
  @override
  ContactsView createState() => new ContactsView();
}

abstract class ContactsState extends State<Contacts> 
                                        with ContactAPI{

  @protected
  bool hasMoreContacts = true;
  bool fetchingInitialContacts = true;
  int page = 0;
  final CacheUtil _cache = new CacheUtil();
  User user;

  var contactWidgetList = new List<Widget>();
  var contacts = new AllContacts();

  @override
  void initState(){
    super.initState();

    getMoreContacts(page);

      
  }


  @protected
  void getMoreContacts(int page) async {
    // await _cache.clearAllUsers();

    user == null
      ? user = await _cache.getCurrentUser()
      : user = user;

    try{
      print(
        "\n-------------------"
        "\nREQUESTING CONTACTS"
        "\n-------------------");

      // request contacts from api
      var newData = await getContacts(user, page, contacts.recentsRequested);

      // update our map with new data
      contacts.addContactsFromList(newData);

      // show loading modal for a second
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        fetchingInitialContacts = false;
        contacts.recentsRequested = true;
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


  @protected
  void getContact(Contact contact) async {
    user == null
      ? user = await _cache.getCurrentUser()
      : user = user;

    if (contact.hasDetails) {
      print('has Details!!!!');
    } else {
      contact = await getContactDetails(contact, user);
    }

    // contact = await 
    Navigator.pushNamed(
      context,
      '/contact',
      arguments: contact
    );
  }
}