import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final String labelText;
  final String type;
  final double ypos;
  final List<String> formFields;
  final Function validator;
  final Size size;
  final int index;


  LoginTextField ({
    @required this.labelText,
    @required this.type,
    @required this.ypos,
    @required this.formFields,
    @required this.validator,
    @required this.size,
    @required this.index
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return new Container(
      padding: EdgeInsets.only(top: ypos),
      child: 
      new Center(
        child:
        new Container(
          width: size.width * 0.8,
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: new Border.all(color: Colors.blue)
          ),
          child:
          new Theme(
            // this colors the underline
            data: theme.copyWith(
              primaryColor: Colors.transparent,
              hintColor: Colors.transparent,
            ),
            child: 
            new TextFormField(
                keyboardType: TextInputType.text,
                obscureText: type == "password",

                decoration: InputDecoration(
                    fillColor: Colors.black.withOpacity(0.6),
                    filled: true,
                    isDense: true,
                    border: new OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    labelText: labelText,
                    labelStyle: new TextStyle(
                        color: Colors.white, fontSize: 16.0)),
                style: TextStyle(fontSize: 20.0, color: Colors.white),

                validator: validator,
                onSaved: (val) => formFields[index] = val,
                autocorrect: false,
            ),
          ),
        ),
      ),
    );
  }
}