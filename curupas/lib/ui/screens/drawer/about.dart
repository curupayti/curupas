import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:curupas/ui/screens/friend_screen.dart';

var currentUserEmail;
var _scaffoldContext;

DocumentReference userRef;

class AboutPage extends StatefulWidget {
  AboutPage({Key key}) : super(key: key);
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[Container(height: height, child: GroupBody())],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

class GroupBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 8.0,
          ),
          UpperSection(),
          MiddleSection(),
        ],
      ),
    );
  }
}

class UpperSection extends StatelessWidget {
  const UpperSection({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: new Stack(fit: StackFit.loose, children: <Widget>[
                  new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Image.asset("assets/images/camadas.png",
                          height: 63.0, width: 300.0, fit: BoxFit.cover),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 100.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(_globals.group.year,
                              style: TextStyle(
                                fontSize: 50.0,
                              )),
                          SizedBox(width: 30.0),
                          new GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FriendsListPage()),
                                );
                              },
                              child: new CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 30.0,
                                child: new Icon(
                                  Icons.group,
                                  color: Colors.white,
                                ),
                              )),
                        ],
                      )),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MiddleSection extends StatelessWidget {
  MiddleSection({
    Key key,
  }) : super(key: key);

  TextStyle defaultStyle = TextStyle(fontSize: 24, color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: new Stack(
                fit: StackFit.loose,
                children: <Widget>[
                  new Center(
                    child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Flexible(
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: defaultStyle,
                                    text:
                                        "Este es un espacio destinado a la camada ",
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: "${_globals.group.year}, ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              " desde sus inicios en infantiles hasta el plantel superior\n\n"),
                                      TextSpan(
                                          text:
                                              "No importa el tiempo que jugaste sino los amigos que hiciste\n\n",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              "Vas a poder compartir imagenes y videos, organizar juntadas y contar anegdotas que quedaran en la historia del club. Coming soon..",
                                          style: TextStyle(fontSize: 18.0)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
