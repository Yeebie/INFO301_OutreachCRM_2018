import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/views/DomainPageView.dart';
import 'package:outreach/api/auth.dart';
import '../view-models/LoginPageState.dart';

class DomainPage extends StatefulWidget {
  @override
  DomainPageView createState() => new DomainPageView();
}

abstract class DomainPageState extends State<DomainPage> {
  @protected
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final List<String> formFields = new List(1);
  bool domainSuccess = false;


  @protected
  submit(BuildContext context) async {
    final form = formKey.currentState;
    if(form.validate()){
      form.save();

      String _domain = formFields[0];

      setState((){
        domainSuccess = true;
      });

      var domainStatus = 
        await ApiAuth.getDomainValidation(_domain, context);

      if(!domainStatus){
        setState((){
          domainSuccess = false;
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => new LoginPage(_domain))
        );
      }
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
