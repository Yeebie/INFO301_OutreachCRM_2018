import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:outreach/models/contact.dart';
import 'package:outreach/view-models/contacts_state.dart';
import 'package:outreach/views/widgets/appbar.dart';
import 'package:outreach/views/widgets/contact_item.dart';
import 'package:outreach/views/widgets/list_header.dart';

class ContactsView extends ContactsState {
  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;
    final double statusbarHeight = MediaQuery.of(context).padding.top;
    // initial loop to build widgets
    loopContactMap(contactMap, 0);

    return new ModalProgressHUD(
        inAsyncCall: fetchingInitialContacts,
        child: Scaffold(
          appBar: new PreferredSize(
            preferredSize: Size.fromHeight(statusbarHeight + 50.0),
            child: new GradientAppBar(
                title: "CONTACTS",
                searchBar: false,
                showBackButton: false
              ),
          ),
          body: new Center(
            child: new Container(
              padding: new EdgeInsets.only(top: 15),
              width: phoneSize.width * 0.9,
              child: ListView.builder(
                itemCount: contactList == null ? 0 : contactList.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index >= contactList.length - 1) {
                    // increase the page number
                    page += 1;
                    // if we can keep requesting: request
                    if (hasMoreContacts) {
                      updateContactList(page);
                      loopContactMap(contactMap, index);
                      return _progressIndicator(phoneSize);
                    }
                  }
                  // return headerOrContact(index);
                  return contactWidgetList[index];
                },
              ),
            ),
          ),
        ));
  }


  /// method to take the contacts map and build a widget for 
  /// every key and entry
  void loopContactMap(Map<String, List<Contact>> map, int index) {
    String currentHeader = "";
    contactWidgetList.clear();
    map.forEach((header, list){
      if(header != currentHeader) {
        
        // build a header widget with list element 0
        print(header);
        print("\t$index : ${list[0].name}, ${list[0].uid}");
        contactWidgetList.add(headerAndContact(index, header, list[0]));
        index++;

        // add widget to list

        // loop over remaining contacts and add them to list
        for(int i = 1; i < list.length; i++) {
          print("\t$index : ${list[i].name}, ${list[i].uid}");
          Widget item = new ContactItem(contact: list[i], index: index);
          contactWidgetList.add(item);
          index++;

        }

        // update the current header
        currentHeader = header;
      } else {

        // loop over all contacts 
        for(int i = 0; i < list.length; i++) {
          print("\t$index : ${list[i].name}, ${list[i].uid}");
          Widget item = new ContactItem(contact: list[i], index: index);
          contactWidgetList.add(item);
          index++;
        }

        // loop every contact and build a widget for each
        // add widget to list
      }
    });
  }


  Widget headerAndContact(int index, String header, Contact c) {
    return new Container(
        child: new Column(
          children: <Widget>[
            new Padding(
                padding: new EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: new ListHeader(headerText: header)),
            new ContactItem(contact: c, index: index)
          ],
        ),
      );
  }

  // Widget headerOrContact(int index) {
  //   // grab the first letter of current contact
  //   String _newLetter = contactList[index].name.substring(0, 1);

  //   // if the new contact name does not begin with current letter
  //   // then return a letter header AND a contact item
  //   if (_newLetter != currentLetter) {
  //     currentLetter = _newLetter;
  //     return new Container(
  //       child: new Column(
  //         children: <Widget>[
  //           new Padding(
  //               padding: new EdgeInsets.fromLTRB(0, 10, 0, 10),
  //               child: new ListHeader(headerText: currentLetter)),
  //           new ContactItem(list: contactList, index: index)
  //         ],
  //       ),
  //     );
  //   } else {
  //     return new ContactItem(list: contactList, index: index);
  //   }
  // }

  Widget _progressIndicator(Size size) {
    return new Container(
      padding: new EdgeInsets.fromLTRB(5, 5, 5, 10),
      child: new Center(child: new CircularProgressIndicator()),
    );
  }
}
