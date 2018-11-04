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
          padding: new EdgeInsets.only(top: 15),
          width: phoneSize.width * 0.9,
          child: ListView.builder(
            itemCount: contacts == null ? 0 : contacts.length,
            itemBuilder: (BuildContext context, int index) {
              return headerOrContact(index);
            },
          ),
        ),
      )
    );
  }

  Widget headerOrContact(int index) {
    // if the new contact does not begin with current letter
    
    String newLetter = contacts[index].substring(0, 1);
    // if(currentLetter == "" || )

    if(newLetter != currentLetter){
      currentLetter = newLetter;
      return new Container(
        child: new Column(
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: contactHeader(contacts[index].substring(0, 1))
            ),
            contactItem(index)
          ],
        ),
      );
    } else {
      return contactItem(index);
    }
  }

  // a method to build a contact
  Widget contactItem(int index){ 
    return new Container(
      child: new Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: new EdgeInsets.only(left: 10),
              child: new Text(
                contacts[index],
                style: new TextStyle(
                  fontSize: 18
                ),
              )
            )
          ),
          new Padding(
            padding: new EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: new Container( // the underline
              decoration: new BoxDecoration(color: Colors.blue),
              height: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget contactHeader(String headerText) {
    headerText = headerText.toUpperCase();

    return new Container(
      decoration: new BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5.0),
      ),
      width: double.infinity,
      child: 
        new Padding(
          padding: new EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: new Text(
            headerText,
            style: new TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]
            ),
          )
        )
    );
  }
}
