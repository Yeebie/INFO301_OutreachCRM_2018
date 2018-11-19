import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/view-models/search_state.dart';
import 'package:outreach/views/widgets/appbar.dart';

class SearchView extends SearchState {
  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;
    final double statusbarHeight = MediaQuery
          .of(context).padding.top;


    return Scaffold(
      appBar: new PreferredSize(
        preferredSize: Size.fromHeight(statusbarHeight + 50.0),
        child: new GradientAppBar(
          title: "SEARCH",
          searchBar: true,
          showBackButton: true,
          search: doContactSearch,
        ),
      ),
      body: new Center(
        child: new Container(
          padding: new EdgeInsets.only(top: 15),
          width: phoneSize.width * 0.9,
          child: new ListView.builder(
            itemCount: contactsFound.length,
            itemBuilder: (BuildContext context, int index){
              return contactsFound[index];
            },
          ),
        ),
      ),
    );
  }
}
