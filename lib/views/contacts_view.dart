import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/view-models/contacts_state.dart';

class ContactsView extends ContactsState {
  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: new AppBar(
        title: new Text("Contacts"),
        elevation: 4.0,
        backgroundColor: Colors.blue[200],
      ),
      body: new Center(
        child: new Container(
          width: phoneSize.width * 0.8,
          decoration: new BoxDecoration(color: Colors.lime),
          child: ListView.builder(
            itemCount: 50,
            itemBuilder: (BuildContext context, int index) {
              return new Text(
                index.toString(),
                style: new TextStyle(
                  
                )
              );
            },
          ),
        ),
      )
    );
  }
}
