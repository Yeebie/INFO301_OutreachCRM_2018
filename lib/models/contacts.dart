// import 'package:flutter/material.dart';
import 'package:outreach/models/contact.dart';

class AllContacts {
  AllContacts();

  // List<Contact> recents;
  bool recentsRequested =false;
  Map<String, List<Contact>> allContacts =new Map<String, List<Contact>>();


  /// method to add a list of `Contact` objects into our map
  void addContactsFromList(List<Contact> contacts){

    // loop over all returned contacts
    // add them to corresponding list header
    for(final contact in contacts){
      // the key is the letter at position 0
      var key = contact.name[0].toUpperCase();

      if(!recentsRequested) {
        key = "RECENTS";
      }

      // put new list in if absent
      allContacts.putIfAbsent(key, () => new List<Contact>());
      // add the contact to the list under that key
      allContacts[key].add(contact);
    }
  }
}