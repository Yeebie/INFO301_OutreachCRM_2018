import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/view-models/search_state.dart';
import 'package:outreach/views/widgets/appbar.dart';

class SearchView extends SearchState {
  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;
    final double statusbarHeight = MediaQuery.of(context).padding.top;
    final theme = Theme.of(context);

    return Scaffold(
        appBar: new PreferredSize(
          preferredSize: Size.fromHeight(statusbarHeight + 50.0),
          child: new GradientAppBar(
            title: "SEARCH",
            searchBar: _searchBar(phoneSize, theme),
            showBackButton: true,
          ),
        ),
        body: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          new Container(
            padding: new EdgeInsets.only(top: 15),
            width: phoneSize.width * 0.9,
            child: contactsFound.length == 0
                ? new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        new Text("Search Something"),
                      ])
                : new ListView.builder(
                    itemCount: contactsFound.length,
                    itemBuilder: (BuildContext context, int index) {
                      return contactsFound[index];
                    },
                  ),
          ),
        ]));
  }

  /// returns a search bar to be used in the appbar
  Widget _searchBar(Size size, ThemeData theme) {
    return new Container(
      width: size.width * 0.73,
      height: 40,
      decoration: new BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.white, width: 2.0)),
      child: new Theme(
        data: theme.copyWith(
          // hide those underlines
          primaryColor: Colors.transparent,
          hintColor: Colors.transparent,
        ),
        child: new Row(children: <Widget>[
          Expanded(
            child: new TextField(
              onChanged: onChangeHandler,
              autofocus: true,
              controller: controller,
              style: new TextStyle(fontSize: 20),
              decoration: new InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0)),
            ),
          ),
          IconButton(
            icon: new Icon(Icons.clear),
            color: Colors.white,
            // set our icon to 5% of the phone width
            iconSize: size.width * 0.05,
            onPressed: (() => controller.clear()),
          ),
        ]),
      ),
    );
  }
}
