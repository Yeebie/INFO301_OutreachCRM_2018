import 'package:outreach/api/contact.dart';
import 'package:outreach/models/contact.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/util/cache_util.dart';
import 'package:outreach/views/search_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/views/widgets/contact_item.dart';
import 'package:outreach/views/widgets/list_header.dart';

import 'dart:async';

class Search extends StatefulWidget {
  @override
  SearchView createState() => new SearchView();
}

abstract class SearchState extends State<Search> with ContactAPI {
  final CacheUtil _cache = new CacheUtil();
  @protected
  List<Widget> contactsFound = new List();
  User user;

  // controller used to clear the text field
  final TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  SearchState() {
    // clears screen and search results
    controller.addListener(() {
      if (controller.text.isEmpty) setState(() => contactsFound.clear());
    });
  }

  Timer searchOnStoppedTyping;

  onChangeHandler(value) {
    const duration = Duration(milliseconds: 800);
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping.cancel()); // clear timer on keypress
    }
    setState(() => searchOnStoppedTyping =
        new Timer(duration, () => doContactSearch(value)));
  }

  @protected
  void doContactSearch(String query) async {
    if (query.isEmpty) {
      setState(() => contactsFound.clear());
      return;
    }
    user == null ? user = await _cache.getCurrentUser() : user = user;

    List<Contact> list = new List();
    contactsFound.clear();

    list = await searchContacts(query, user);

    String headerText = "${list.length.toString()} RESULTS";
    ListHeader header = new ListHeader(headerText: headerText);
    SizedBox padding = SizedBox(height: 10,);
    contactsFound.add(header);
    contactsFound.add(padding);

    for (Contact c in list) {
      ContactItem cItem = new ContactItem(contact: c);
      contactsFound.add(cItem);
    }
    setState(() {
      // do something
    });
  }
}
