import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/util/helpers.dart';

class SettingsDrawer extends StatefulWidget {
  final User user;

  SettingsDrawer ({
    @required this.user,
  });

  @override
  _MySettingsDrawer createState() => _MySettingsDrawer();
}

class _MySettingsDrawer extends State<SettingsDrawer> {
  
  // attempting async logout call
  bool loggingOut = false;

  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;
    return new Drawer(
      child: new ModalProgressHUD(
        inAsyncCall: loggingOut,
        child: ListView(
        children: <Widget>[
          _userAccountHeader(phoneSize),
          _contactUs(),
          new Container(
            height: phoneSize.height * .05,
          ),
          _logout(context),
          _copyright()
        ],
      ),
      ),
    );
  }

  Widget _userAccountHeader(Size size){
    return new UserAccountsDrawerHeader(
      accountName: new Text(widget.user.name),
      accountEmail: new Text(widget.user.username),
      currentAccountPicture: 
      new Icon(
        Icons.account_circle,
        color: Colors.white,
        size: size.width * .16,
      ),
      decoration: BoxDecoration(
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
      ),
    );
  }

  Widget _contactUs(){
    return new ListTile(
      title: new Text("Contact Us"),
      trailing: new Icon(Icons.arrow_right),
      onTap: _launchURL,
    );
  }

  Widget _logout(BuildContext context){
    return new ListTile(
      title: new Text("Logout"),
      trailing: new Icon(Icons.close),
      onTap: (() {
        Util.showDialogParent(
          "Confirm Logout",
          "Are you sure you wish to logout?",
          context,
          true
        ).then((bool accepted) {
          if(accepted){
            Util.logout(context);
            setState(() {
              loggingOut = true;
            });
          }
        });
      }),
    );
  }

  Widget _copyright(){
    return TextField(
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Copyright Outreach CRM 2018 ©'
      ),
    );
  }

  void _launchURL() async {
    print("-- launch contact us --");
  }
}