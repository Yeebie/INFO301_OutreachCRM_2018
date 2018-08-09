import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  @override
  _SearchBar createState() => new _SearchBar();
}


class _SearchBar extends State<ContactsPage> {
  Widget appBarTitle = new Text("Search Contacts...");
  Icon actionIcon = new Icon(Icons.search);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          title:appBarTitle,
          actions: <Widget>[
            new IconButton(icon: actionIcon,onPressed:(){
              setState(() {
                if ( this.actionIcon.icon == Icons.search){
                  this.actionIcon = new Icon(Icons.close);
                  this.appBarTitle = new TextField(
                    style: new TextStyle(
                      color: Colors.white,

                    ),
                    decoration: new InputDecoration(
                        prefixIcon: new Icon(Icons.search,color: Colors.white),
                        hintText: "Search...",
                        hintStyle: new TextStyle(color: Colors.white)
                    ),
                  );}
// Code for search bar from: https://stackoverflow.com/questions/49966980/how-to-create-toolbar-searchview-in-flutter*/

              });
            } ,),]
      ),
    );
  }
}

