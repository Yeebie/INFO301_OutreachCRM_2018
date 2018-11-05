import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget {
  final bool searchBar;
  final String title;
  final double barHeight = 50.0;
  final bool showBackButton;

  GradientAppBar({
    @required this.searchBar,
    @required this.title,
    @required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;
    final Size phoneSize = MediaQuery.of(context).size;

    return new Container(
      padding: new EdgeInsets.only(top: statusbarHeight),
      decoration: _gradientDecoration(),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _showBackButton(context, showBackButton),
          _titleSection(title, phoneSize),
          _searchButton(),
          _settingsButton(),
      ]),
    );
  }


  /// method to show the back button based on boolean passed
  Widget _showBackButton(BuildContext context, bool showButton){
    if(showButton){
      return IconButton(
        icon: new Icon(Icons.arrow_back_ios),
        onPressed: () {
          if(Navigator.of(context).canPop()){
            Navigator.of(context).pop();
          }
        },
        iconSize: 30,
        color: Colors.white,
      );
     } else { 
       return Container();
     }
  }

  Widget _searchButton(){
    return IconButton(
      icon: new Icon(Icons.search),
      color: Colors.white,
      iconSize: 30,
      onPressed: (() => print("search")),
    );
  }

  Widget _settingsButton(){
    return IconButton(
      icon: new Icon(Icons.settings),
      onPressed: (() => print("settings")),
      iconSize: 30,
      color: Colors.white,
    );
  }

  Widget _titleSection(String title, Size size) {
    return 
    new Expanded(
      child: new Container(
        padding: new EdgeInsets
        .only(left: showBackButton 
              ? size.width * 0.1 
              : size.width * 0.2
            ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Text(
              title,
              // textAlign: TextAlign.right,
              style: new TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: 1
              ),
            ),
          ]
        )
      )
    );
  }


  BoxDecoration _gradientDecoration() {
    return new BoxDecoration(
        gradient: new LinearGradient(
            colors: [
              const Color(0xF4A8AC9).withOpacity(0.3),
              const Color(0xFF0E598F)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
        boxShadow: [
          new BoxShadow(
            color: Colors.grey[500],
            blurRadius: 20.0,
            spreadRadius: 1.0,
          )
        ]);
  }
}
