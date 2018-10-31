import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:outreach/util/helpers.dart';
import 'package:outreach/view-models/domain_state.dart';
import 'package:outreach/views/widgets/login_text_field.dart';

class DomainPageView extends DomainPageState {
  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;
    double verticalPadding = phoneSize.height * 0.05;

    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: new GestureDetector(
        onTap: () {
          Util.hideSoftKeyboard(context);
        },
        child: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/background-image.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: new ModalProgressHUD(
            inAsyncCall: domainSuccess,
            child: new ListView(
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
                    child: new Stack(children: <Widget>[
                      new Column(children: <Widget>[
                        new LoginTextField(
                            labelText: 'Domain',
                            type: 'domain',
                            index: 0,
                            ypos: verticalPadding,
                            size: phoneSize,
                            validator: validateDomain,
                            formFields: formFields),
                        new Container(
                          width: phoneSize.width * 0.75,
                          margin: EdgeInsets.only(top: verticalPadding),
                          child: new Material(
                            borderRadius: BorderRadius.circular(30.0),
                            shadowColor: Colors.lightBlueAccent.shade100,
                            elevation: 5.0,
                            color: domainSuccess
                                ? Colors.grey
                                : Color(0xFF0085CA),
                            child: MaterialButton(
                              height: phoneSize.height * 0.08,
                              onPressed: () {
                                domainSuccess //if submit was called, lock button
                                    ? print("button disabled")
                                    : submit(context);
                                      Util.hideSoftKeyboard(context);
                              },
                              child: new Text(
                                "NEXT",
                                style: TextStyle(
                                    fontSize: 17.0, color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      ])
                    ]))
              ],
            ),
          ),
        )
      )
    );
  }
}
