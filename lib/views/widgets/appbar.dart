import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget {
  final bool searchBar;
  final String title;
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
      child: 
      
      searchBar

      ? new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _showBackButton(context, showBackButton, phoneSize),
            _searchBar(phoneSize),
            _settingsButton(phoneSize),
        ])

      : new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _showBackButton(context, showBackButton, phoneSize),
            _titleSection(title, phoneSize),
            _searchButton(phoneSize),
            _settingsButton(phoneSize),
        ]),
    );
  }


  Widget _searchBar(Size size){
    return new Container(
      width: size.width * 0.73,
      height: 40,
      decoration: new BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: new TextField(
        
      ),
    );
  }

  Widget _titleSection(String title, Size size) {
    return new Expanded(
      child: new Container(
        padding: new EdgeInsets
        .only(left: showBackButton 
              ? size.width * 0.1 
              : size.width * 0.235
            ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Text(
              title,
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

/// method to show the back button based on boolean passed
  Widget _showBackButton(BuildContext context, bool showButton, Size size){
    if(showButton){
      return IconButton(
        icon: new Icon(Icons.arrow_back_ios),
        onPressed: () {
          if(Navigator.of(context).canPop()){
            Navigator.of(context).pop();
          }
        },
        iconSize: size.width * 0.09,
        color: Colors.white,
      );
     } else { 
       return Container();
     }
  }

  Widget _searchButton(Size size){
    return IconButton(
      icon: new Icon(Icons.search),
      color: Colors.white,
      iconSize: size.width * 0.09,
      onPressed: (() => print("search")),
    );
  }

  Widget _settingsButton(Size size){
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget> [
        new IconButton(
          icon: new Icon(Icons.settings),
          onPressed: (() => print("settings")),
          iconSize: size.width * 0.09,
          color: Colors.white,
        )
      ]);
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
