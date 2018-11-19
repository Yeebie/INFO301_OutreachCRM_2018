import 'package:outreach/api/contact.dart';
import 'package:outreach/models/contact.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/util/cache_util.dart';
import 'package:outreach/views/search_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/views/widgets/contact_item.dart';
import 'package:outreach/views/widgets/list_header.dart';

class Search extends StatefulWidget {
  @override
  SearchView createState() => new SearchView();
}

abstract class SearchState extends State<Search> 
                                    with ContactAPI {
  final CacheUtil _cache = new CacheUtil();
  @protected
  List<Widget> contactsFound = new List();
  User user;

  @override
  void initState(){
    super.initState();
  }

  @protected
  void doContactSearch(String query) async {
    user == null 
      ? user = await _cache.getCurrentUser()
      : user = user;
    
    List<Contact> list = new List();
    contactsFound.clear();

    list = await searchContacts(query, user);

    String headerText = "${list.length.toString()} RESULTS";
    ListHeader header = new ListHeader(headerText: headerText);
    contactsFound.add(header);

    for(Contact c in list){
      ContactItem cItem = new ContactItem(contact: c);
      contactsFound.add(cItem);
    }
    setState(() {
          
    });
  }
}