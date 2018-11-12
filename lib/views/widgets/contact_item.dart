import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/models/contact.dart';

class ContactItem extends StatelessWidget {
  // final List<Contact> list;
  final Contact contact;

  ContactItem({
    @required this.contact,
  });

  @override
  Widget build(BuildContext context){

    String _contactName = contact.name;


    return new GestureDetector(
      onTap: () {
        // call a method to push to details page
        String _oid = (contact.uid);
        print("OID: $_oid");
      },
      child: new Container(
        decoration: new BoxDecoration(
          // we need this for the gesture detector 
          // to render the whole container
          color: Colors.transparent
        ),
        width: double.infinity,
        child: new Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: new EdgeInsets.fromLTRB(10,5,0,0),
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
      ),
    );
  }
}
