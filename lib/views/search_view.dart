import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/models/contact.dart';
import 'package:outreach/view-models/search_state.dart';
import 'package:outreach/views/widgets/appbar.dart';

class SearchView extends SearchState {
  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;
    List<Contact> contacts = doContactSearch() ?? new List();
    final double statusbarHeight = MediaQuery
          .of(context).padding.top;


    return Scaffold(
      appBar: new PreferredSize(
        preferredSize: Size.fromHeight(statusbarHeight + 50.0),
        child: new GradientAppBar(
          title: "SEARCH",
          searchBar: true,
          showBackButton: true
        ),
      ),
      body: new Container(
        // results
      ),

    );
  }
}
