import 'package:outreach/api/contact.dart';
import 'package:outreach/models/contact.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/util/cache_util.dart';
import 'package:outreach/views/search_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  SearchView createState() => new SearchView();
}

abstract class SearchState extends State<Search> 
                                    with ContactAPI {
  final CacheUtil _cache = new CacheUtil();

  @override
  void initState(){
    super.initState();
    print("IM BEING CALLED");
    doContactSearch();
  }

  @protected
  Future<List<Contact>> doContactSearch() async {
    User user = await _cache.getCurrentUser();
    List<Contact> list = new List();

    list = await searchContacts("doc", user);
    return list;
  }
}