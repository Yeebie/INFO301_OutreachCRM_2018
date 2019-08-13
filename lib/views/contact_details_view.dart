import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/models/contact.dart';
import 'package:outreach/view-models/contact_details_state.dart';

class ContactDetailsView extends ContactDetailsState {
  @override
  Widget build(BuildContext context) {
    final Contact contact = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: new AppBar(
        title: new Text(contact.name),
      ),
      body: new Container(
        child: new Center(
          child: new Text(
            'hey x :' + contact.uid,
          ),
        ),
      ),
    );
  }
}
