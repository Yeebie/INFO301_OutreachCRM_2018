import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/view-models/LoginPageState.dart';
import 'package:outreach/views/widgets/LoginTextField.dart';

class LoginPageView extends MyLoginPageState {

  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;
    double verticalPadding = phoneSize.height * 0.05;


    return Scaffold(
      resizeToAvoidBottomPadding: false,
        body: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/background-image.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: 
          new ListView(
            children: <Widget>[
              new Center( child: 
              new Container(
                height: phoneSize.height * 0.25,
                width: phoneSize.width * 0.75,
                margin: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 30.0),
                child: new Image.asset(
                  'assets/images/OutreachCRM_vert_logo.png',
                  fit: BoxFit.contain,
                ))),
              new Form(
                key: formKey,
                child:
                new Stack(
                  children: <Widget>[
                    new Column(children: <Widget>[

                      new LoginTextField(labelText: 'Username', type: 'username', index: 0,
                      ypos: verticalPadding, size: phoneSize, validator: validateUserName,
                      formFields: formFields),

                      new LoginTextField(labelText: 'Password', type: 'password', index: 1,
                      ypos: verticalPadding, size: phoneSize, validator: validatePassword,
                      formFields: formFields)
                    ])
                  ]
                )
              )
            ],
          ),
        ),
    );
  }
}