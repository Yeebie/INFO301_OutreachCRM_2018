import 'package:flutter/material.dart';
import 'package:outreach/view-models/domain_state.dart';
import 'package:outreach/view-models/contacts_state.dart';
import 'package:outreach/view-models/search_state.dart';
import 'package:outreach/view-models/contact_details_state.dart';
// import 'package:outreach/view-models/splash_state.dart';

final routes = {
  // '/': (BuildContext context) => new Splash(),
  '/domain': (BuildContext context) => new DomainPage(),
  '/contacts': (BuildContext context) => new Contacts(),
  '/search': (BuildContext context) => new Search(),
  '/contact': (BuildContext context) => new ContactDetails()
};