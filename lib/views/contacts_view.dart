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
    _buildContactItemList(contactMap, 0);

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
                itemCount: contactWidgetList == null ? 0 : contactWidgetList.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index >= contactWidgetList.length - 1) {
                    // increase the page number
                    // page++;
                    // if we can keep requesting: request
                    if (hasMoreContacts) {
                      getMoreContacts(page++);
                      _buildContactItemList(contactMap, index);
                      return _progressIndicator(phoneSize);
                    }
                  }
                  return contactWidgetList[index];
                },
              ),
            ),
          ),
        ));
  }


  /// method to take the contacts map and build a widget for 
  /// every key and entry, then add widget to list
  void _buildContactItemList(Map<String, List<Contact>> map, int index) {

    String currentHeader = "";
    // if(!recentsRequested) currentHeader = "recents";
    contactWidgetList.clear();

    // for every header, list
    map.forEach((header, list){
      if(header != currentHeader) {
        // update the current header
        currentHeader = header;

        // build a header widget with contact list[0]
        print(" - "+header);
        print("\t$index : ${list[0].name}, ${list[0].uid}");
        contactWidgetList.add(headerAndContact(currentHeader, list[0]));
        index++;

        // loop over remaining contacts and add them to list
        for(int i = 1; i < list.length; i++) {
          print("\t$index : ${list[i].name}, ${list[i].uid}");
          Widget item = new ContactItem(contact: list[i]);
          contactWidgetList.add(item);
          index++;
        }

        
      } 
      else {
        // loop every contact and build a widget for each
        for(int i = 0; i < list.length; i++) {
          print("\t$index : ${list[i].name}, ${list[i].uid}");
          Widget item = new ContactItem(contact: list[i]);
          contactWidgetList.add(item);
          index++;
        }
      }
    });
  }


  Widget headerAndContact(String header, Contact contact) {
    return new Container(
        child: new Column(
          children: <Widget>[
            new Padding(
                padding: new EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: new ListHeader(headerText: header)),
            new ContactItem(contact: contact)
          ],
        ),
      );
  }

  Widget _progressIndicator(Size size) {
    return new Container(
      padding: new EdgeInsets.fromLTRB(5, 5, 5, 10),
      child: new Center(child: new CircularProgressIndicator()),
    );
  }
}
