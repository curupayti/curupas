  import "package:flutter/material.dart";
  import 'package:curupas/globals.dart' as _globals;
  import 'package:curupas/models/streaming.dart';

  class StreamingPage extends StatefulWidget {
    StreamingPage({Key key}) : super(key: key);
    @override
    _StreamingPageState createState() => _StreamingPageState();
  }

  class _StreamingPageState extends State<StreamingPage> {
    @override
    Widget build(BuildContext context) {
      return Container(
        child: HomeStream(),
      );
    }

    @override
    void initState() {
      super.initState();
    }
  }

  class HomeStream extends StatefulWidget {
    @override
    _HomeStreamState createState() => new _HomeStreamState();
  }

  class _HomeStreamState extends State<HomeStream> {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[HomeScreeTopPart(), HomeScreenBottomPart()],
          ),
        ),
      );
    }
  }

  class HomeScreeTopPart extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      if (!_globals.streamingReachable) {
        return Stack(children: <Widget>[
          new Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: new Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
                    child: new Image.asset("assets/images/not_available.png",
                        height: 100.0, width: 100.0, fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: new Text(
                    "El servicio de streaming \n no se encuentra disponible",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.none,
                      fontSize: 25.0,
                      fontWeight: FontWeight.w300,
                      fontFamily: "OpenSans",
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: new Text(
                    "Volve a intentarlo mas tarde por favor",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.none,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w300,
                      fontFamily: "OpenSans",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]);
      } else {
        return new Container(
          height: 320.0,
          child: Stack(
            children: <Widget>[
              ClipPath(
                clipper: Mclipper(),
                child: Container(
                  height: 270.0,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.0, 10.0),
                        blurRadius: 10.0)
                  ]),
                  child: Stack(
                    children: <Widget>[
                      Image.network(
                          _globals.streammer.activeStreaming.thumnailUrl,
                          fit: BoxFit.cover,
                          width: double.infinity),
                      Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                              const Color(0x00000000),
                              const Color(0xD9333333)
                            ],
                                stops: [
                              0.0,
                              0.9
                            ],
                                begin: FractionalOffset(0.0, 0.0),
                                end: FractionalOffset(0.0, 1.0))),
                        child: Padding(
                          padding: EdgeInsets.only(left: 95.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _globals.streammer.activeStreaming.title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40.0,
                                    fontFamily: "SF-Pro-Display-Bold"),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 270.0,
                right: -20.0,
                child: FractionalTranslation(
                  translation: Offset(0.0, -0.5),
                  child: Row(
                    children: <Widget>[
                      FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/videoplayer',
                            arguments: _globals.streammer.activeStreaming,
                          );
                        },
                        child: Icon(
                          Icons.play_circle_filled,
                          color: Color(0xFFbf0411),
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: RaisedButton(
                          onPressed: () {},
                          color: Color(0xFF001d7e),
                          padding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 40.0),
                          child: Row(
                            children: <Widget>[
                              RotatedBox(
                                quarterTurns: 2,
                                child: Icon(_globals.streammer.videoIcon,
                                    size: 30.0, color: Color(0xFFe2d504)),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Text(
                                _globals.streammer
                                    .showLivestreamingMessage, //"Mirar Ahora",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontFamily: "SF-Pro-Display-Bold"),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }
    }
  }

  class HomeScreenBottomPart extends StatelessWidget {
    List<Widget> movies() {
      List<Widget> movieList = new List();
      for (int i = 0; i < 3; i++) {
        var movieitem = Padding(
          padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 12.0),
          child: new GestureDetector(
            onTap: () {
              print("Container clicked");
            },
            child: Container(
              height: 220.0,
              width: 135.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10.0,
                        offset: Offset(0.0, 10.0))
                  ]),
              child: Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0)),
                    child: Image.network(
                      _globals.streammer.streamings[i].thumnailUrl,
                      width: double.infinity,
                      height: 130.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0),
                    child: Text(_globals.streammer.streamings[i].title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16.0, fontFamily: "SF-Pro-Display-Bold")),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 3.0),
                    child: Text(i == 0 ? "Season 2" : ""),
                  )
                ],
              ),
            ),
          ),
        );
        movieList.add(movieitem);
      }
      return movieList;
    }

    @override
    Widget build(BuildContext context) {
      return new Container(
        height: 360.0,
        margin: EdgeInsets.only(left: 45.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Mirar ahora",
                    style: TextStyle(
                        fontSize: 22.0, fontFamily: "SF-Pro-Display-Bold"),
                  ),
                  FlatButton(
                    child: Text("Ver mas"),
                    onPressed: () {},
                  )
                ],
              ),
            ),
            Container(
              height: 280.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: movies(),
              ),
            )
          ],
        ),
      );
    }
  }

  class Mclipper extends CustomClipper<Path> {
    @override
    Path getClip(Size size) {
      var path = new Path();
      path.lineTo(0.0, size.height - 100.0);

      var controlpoint = Offset(35.0, size.height);
      var endpoint = Offset(size.width / 2, size.height);

      path.quadraticBezierTo(
          controlpoint.dx, controlpoint.dy, endpoint.dx, endpoint.dy);

      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0.0);

      return path;
    }

    @override
    bool shouldReclip(CustomClipper<Path> oldClipper) {
      return true;
    }
  }
