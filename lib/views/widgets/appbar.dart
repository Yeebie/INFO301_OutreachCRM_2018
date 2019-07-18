import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A class for building an app bar based
/// on dynamic variables passed to the
/// constructor. e.g. back button or not
class GradientAppBar extends StatelessWidget {

// final bool searchBar;
final String title;
final bool showBackButton;
final GlobalKey<ScaffoldState> scaffoldKey;

final Widget searchBar;

GradientAppBar({
  @required this.title,
  @required this.showBackButton,
  this.searchBar,
  this.scaffoldKey,
});

  @override
  Widget build(BuildContext context) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;
    final Size phoneSize = MediaQuery.of(context).size;

    return new Container(
      padding: new EdgeInsets.only(top: statusbarHeight),
      decoration: _gradientDecoration(),
      child: searchBar != null
          ? new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                  _showBackButton(context, showBackButton, phoneSize),
                  searchBar,
                  _settingsButton(phoneSize),
                ])
          : new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                  _showBackButton(context, showBackButton, phoneSize),
                  _titleSection(title, phoneSize),
                  _searchButton(phoneSize, context),
                  _settingsButton(phoneSize),
                ]),
    );
  }


  Widget _titleSection(String title, Size size) {
    return new Expanded(
        child: new Container(
            padding: new EdgeInsets.only(
                left: showBackButton ? size.width * 0.1 : size.width * 0.235),
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
                        letterSpacing: 1),
                  ),
                ])));
  }

  /// method to return the back button or an empty
  /// container, based on a boolean passed to the class
  Widget _showBackButton(BuildContext context, bool showButton, Size size) {
    if (showButton) {
      return IconButton(
        icon: new Icon(Icons.arrow_back_ios),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
        // set our icon to 9% of the phone width
        iconSize: size.width * 0.09,
        color: Colors.white,
      );
    } else {
      return Container();
    }
  }

  /// returns the search button for the appbar
  Widget _searchButton(Size size, BuildContext context) {
    return IconButton(
      icon: new Icon(Icons.search),
      color: Colors.white,
      // set our icon to 9% of the phone width
      iconSize: size.width * 0.09,
      onPressed: (() =>
        Navigator.of(context).pushNamed('/search'))
    );
  }

  /// returns the settings button for the appbar
  Widget _settingsButton(Size size) {
    return new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new IconButton(
            icon: new Icon(Icons.settings),
            onPressed: (() => scaffoldKey.currentState.openDrawer()),
            // set our icon to 9% of the phone width
            iconSize: size.width * 0.09,
            color: Colors.white,
          )
        ]);
  }

  /// this method defines the custom gradient
  /// object used to style our app bar
  BoxDecoration _gradientDecoration() {
    return new BoxDecoration(
      gradient: new LinearGradient(
        colors: [
          const Color(0xFF0E598F),
          const Color(0xFF0085CA).withOpacity(0.6),
          const Color(0xFF0E598F),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.5, 1.0],
        tileMode: TileMode.clamp
      ),
      boxShadow: [
        new BoxShadow(
          color: Colors.grey[400],
          blurRadius: 20.0,
          spreadRadius: 1.0,
        )
      ]
    );
  }
}
