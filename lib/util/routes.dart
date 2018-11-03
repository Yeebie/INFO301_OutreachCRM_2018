import 'package:flutter/material.dart';
import 'package:outreach/view-models/domain_state.dart';
import 'package:outreach/view-models/contacts_state.dart';
// import 'package:outreach/view-models/splash_state.dart';

final routes = {
  // '/': (BuildContext context) => new Splash(),
  '/domain': (BuildContext context) => new DomainPage(),
  '/contacts': (BuildContext context) => new Contacts()
};