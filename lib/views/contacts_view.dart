import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:outreach/view-models/contacts_state.dart';

class ContactsView extends ContactsState {

  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;

    return Scaffold(
      // this will be a widget when I'm ready for it
      appBar: new PreferredSize(
        preferredSize: Size.fromHeight(phoneSize.height * 0.11),
        child: new AppBar(
          centerTitle: true,
          title: new Text(
            "CONTACTS",
            style: new TextStyle(
              fontSize: 23,
            ),),
          elevation: 4.0,
          backgroundColor: const Color(0xFF4A8AC9),
          actions: <Widget>[
            IconButton(
              icon: new Icon(Icons.search),
              color: Colors.white,
              iconSize: 30,
              onPressed: (() => print("search")),
            ),

            IconButton(
              icon: new Icon(Icons.settings),
              onPressed: (() => print("settings")),
              iconSize: 30,
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: new Center(
        child: new Container(
          padding: new EdgeInsets.only(top: 15),
          width: phoneSize.width * 0.9,
          child: ListView.builder(
            itemCount: contactList == null ? 0 : contactList.length,

            itemBuilder: (BuildContext context, int index) {
              if(index >= contactList.length-1) {
                // increase the page number
                page+=1;
                // if we can keep requesting: request
                if (hasMoreContacts) {
                  updateContactList(page);
                  return _progressIndicator(phoneSize);
                }
              }
              return headerOrContact(index);
            },
          ),
        ),
      )
    );
  }

  Widget headerOrContact(int index) {
    
    // grab the first letter of current contact
    String _newLetter = contactList[index].name.substring(0, 1);

  // if the new contact name does not begin with current letter
  // then return a letter header AND a contact item
    if(_newLetter != currentLetter){
      currentLetter = _newLetter;
      return new Container(
        child: new Column(
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: contactHeader(currentLetter)
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
    String _contactName = contactList[index].name;
    return new Container(
      child: new Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: new EdgeInsets.only(left: 10),
              child: new Text(
                _contactName,
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

  Widget _progressIndicator(Size size){
    return new Container(
      padding: new EdgeInsets.all(5),
      child: new Center(
        child: new CircularProgressIndicator()
      ),
    );
  }
}
