import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget{
  final bool searchBar;
  final String title;
  final double barHeight = 50.0;

  GradientAppBar({
    @required this.searchBar,
    @required this.title,
  });

  @override
  Widget build(BuildContext context){
    final double statusbarHeight = MediaQuery
          .of(context)
          .padding
          .top;
    
    return new Container(
      padding: new EdgeInsets.only(top: statusbarHeight),
      child: new Center(
        child: new Text(
          title,
          style: new TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            letterSpacing: 1
          ),
        )
      ),
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [
            const Color(0xF4A8AC9).withOpacity(0.3),
            const Color(0xFF0E598F)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp
        ),
        boxShadow:  [
          new BoxShadow(
            color: Colors.grey[500],
            blurRadius: 20.0,
            spreadRadius: 1.0,
          )
        ]
      ),
    );
  }


// new PreferredSize(
//         preferredSize: Size.fromHeight(phoneSize.height * 0.11),
//         child: new AppBar(
//           centerTitle: true,
//           title: new Text(
//             "CONTACTS",
//             style: new TextStyle(
//               fontSize: 23,
//             ),),
//           elevation: 4.0,
//           backgroundColor: const Color(0xFF4A8AC9),
//           actions: <Widget>[
//             IconButton(
//               icon: new Icon(Icons.search),
//               color: Colors.white,
//               iconSize: 30,
//               onPressed: (() => print("search")),
//             ),

//             IconButton(
//               icon: new Icon(Icons.settings),
//               onPressed: (() => print("settings")),
//               iconSize: 30,
//               color: Colors.white,
//             ),
//           ],
//         ),
//       ),
}