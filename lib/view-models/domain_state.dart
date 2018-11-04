import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/util/helpers.dart';
import 'package:outreach/views/domain_view.dart';
import 'package:outreach/api/auth.dart';
import 'package:outreach/view-models/login_state.dart';

class DomainPage extends StatefulWidget {
  @override
  DomainPageView createState() => new DomainPageView();
}

abstract class DomainPageState extends State<DomainPage> {
  @protected
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  final List<String> formFields = new List(1);
  bool domainSuccess = false;

  ApiAuth auth = new ApiAuth();


  @protected
  submit(BuildContext context) async {
    var domainAccepted;

    final form = formKey.currentState;
    if(form.validate()){
      form.save();

      String _domain = formFields[0];

      setState(() => domainSuccess = true);

      try {
        domainAccepted = 
            await auth.validateDomain(_domain);
      } on ConnectionException catch(e) {
        Util.showSnackBar(
            e.error,
            scaffoldKey,
            true
        );
        setState(() => domainSuccess = false);
      }

      if(!domainAccepted) {
        Util.showSnackBar(
            "Please enter a valid domain",
            scaffoldKey,
            true
        );
        setState(() => domainSuccess = false);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => new LoginPage(_domain))
        );
      }

      // hide modal if we pop back to page
      domainSuccess = false;
    }
  }

  @protected
  String validateDomain(String val){
    RegExp domainPattern = new RegExp(
      r"^[a-zA-Z0-9]*$",
      caseSensitive: false,
      multiLine: false,
    );

    print("Entered Domain: " + val);
    if (val.isEmpty) {
      return 'Please enter some text';
    } else if (!domainPattern.hasMatch(val)) {
      return 'Only enter alphanumeric characters';
    } 
    return null;
  }
}
