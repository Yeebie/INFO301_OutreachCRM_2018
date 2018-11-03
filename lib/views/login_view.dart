import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:outreach/util/helpers.dart';
import 'package:outreach/view-models/login_state.dart';
import 'package:outreach/views/widgets/login_text_field.dart';

class LoginView extends LoginState {
  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;
    double verticalPadding = phoneSize.height * 0.05;
    ScrollController _scrollController = new ScrollController();
    var _focusNode = new FocusNode();
    // var _focusNode2 = new FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        // FocusScope.of(context).requestFocus(_focusNode);
      }
    });

    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomPadding: !false,
        body: new GestureDetector(
          onTap: () {
            Util.hideSoftKeyboard(context);
            _scrollController.jumpTo(_scrollController.position.minScrollExtent);
          },
          child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('assets/images/background-image.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: new ModalProgressHUD(
              inAsyncCall: attemptingLogin,
              child: new ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                children: <Widget>[
                  new Center(
                      child: new Container(
                          height: phoneSize.height * 0.25,
                          width: phoneSize.width * 0.75,
                          margin:
                              const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 30.0),
                          child: new Image.asset(
                            'assets/images/OutreachCRM_vert_logo.png',
                            fit: BoxFit.contain,
                          ))),
                  new Form(
                    key: formKey,
                    child: new Stack(
                      children: <Widget>[
                        new Column(children: <Widget>[
                          new LoginTextField(
                              labelText: 'Username',
                              type: 'username',
                              index: 0,
                              ypos: verticalPadding,
                              size: phoneSize,
                              validator: validateUserName,
                              formFields: formFields,
                          ),

                          new LoginTextField(
                            labelText: 'Password',
                            type: 'password',
                            index: 1,
                            ypos: verticalPadding,
                            size: phoneSize,
                            validator: validatePassword,
                            formFields: formFields,
                          ),

                          new Container(
                            width: phoneSize.width * 0.75,
                            margin: EdgeInsets.fromLTRB(
                                0, verticalPadding, 0, phoneSize.height * .10),
                            child: new Material(
                              borderRadius: BorderRadius.circular(30.0),
                              shadowColor: Colors.lightBlueAccent.shade100,
                              elevation: 5.0,
                              color: attemptingLogin
                                  ? Colors.grey
                                  : Color(0xFF0085CA),
                              child: MaterialButton(
                                height: phoneSize.height * 0.08,
                                onPressed: () {
                                  attemptingLogin
                                      ? print("button disabled")
                                      : submit();
                                  
                                  Util.hideSoftKeyboard(context);
                                },
                                child: new Text(
                                  "LOGIN",
                                  style: TextStyle(
                                      fontSize: 17.0, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ])
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
