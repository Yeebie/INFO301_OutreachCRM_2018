import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A class for building an app bar based
/// on dynamic variables passed to the
/// constructor. e.g. back button or not
class GradientAppBar extends StatelessWidget {
  final bool searchBar;
  final String title;
  final bool showBackButton;
  final void Function(String) search;
  final GlobalKey<ScaffoldState> scaffoldKey;

  // controller used to clear the text field
    final TextEditingController _controller = new TextEditingController();

  GradientAppBar({
    @required this.searchBar,
    @required this.title,
    @required this.showBackButton,
    this.search,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;
    final Size phoneSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return new Container(
      padding: new EdgeInsets.only(top: statusbarHeight),
      decoration: _gradientDecoration(),
      child: searchBar
          ? new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                  _showBackButton(context, showBackButton, phoneSize),
                  _searchBar(phoneSize, theme),
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

  /// returns a search bar to be used in the appbar
  Widget _searchBar(Size size, ThemeData theme) {
     _controller.addListener(_doSomething);

    return new Container(
      width: size.width * 0.73,
      height: 40,
      decoration: new BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.white, width: 2.0)),
      child: new Theme(
        data: theme.copyWith(
          // hide those fucking underlines
          primaryColor: Colors.transparent,
          hintColor: Colors.transparent,
        ),
        child: new Row(
          children: <Widget>[
          Expanded(
            child: new TextField(
              onChanged: (val) {

              },
              autofocus: true,
              controller: _controller,
              style: new TextStyle(fontSize: 20),
              decoration: new InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0)),
            ),
          ),
          IconButton(
            icon: new Icon(Icons.clear),
            color: Colors.white,
            // set our icon to 5% of the phone width
            iconSize: size.width * 0.05,
            onPressed: (() => _controller.clear()),
          ),
        ]),
      ),
    );
  }

  void _doSomething(){
    if(_controller.text != null){
      search(_controller.text);
    }
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
