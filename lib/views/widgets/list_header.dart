import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListHeader extends StatelessWidget {
  final String headerText;

  ListHeader({
    @required this.headerText,
  }); 

  @override
  Widget build(BuildContext context){
    return new Container(
      decoration: new BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5.0),
      ),
      width: double.infinity,
      child: 
        new Padding(
          padding: new EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: new Text(
            headerText,
            style: new TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]
            ),
          )
        )
    );
  }


}