import 'package:curupas/business/cache.dart';
import 'package:curupas/globals.dart' as _globals;
import "package:flutter/material.dart";
import 'package:flutter_spinkit/flutter_spinkit.dart';

class StreamingPage extends StatefulWidget {
  StreamingPage({Key key}) : super(key: key);
  @override
  _StreamingPageState createState() => _StreamingPageState();
}

class _StreamingPageState extends State<StreamingPage> {
  bool _loading = true;
  int _counting = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: HomeStream(_loading),
    );
  }

  @override
  void initState() {
    super.initState();
    if (_globals.streaming_data_loaded == false) {
      _globals.getStreamingCollected();
      _globals.eventBus.on().listen((event) {
        String _event = event.toString();
        if (_event.contains("streaming")) {
          _counting = _counting + 1;
          if (_counting == 1) {
            _counting = 0;
            setState(() {
              _loading = false;
            });
          }
        }
        print("Counting : ${_counting}");
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  void loaded() {
    _globals.streaming_data_loaded = true;
    setState(() {
      _loading = false;
    });
  }
}

class HomeStream extends StatefulWidget {
  final bool loading;

  HomeStream(this.loading);

  @override
  _HomeStreamState createState() => new _HomeStreamState();
}

class _HomeStreamState extends State<HomeStream> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: HomeScreeAbovePart(widget.loading),
    );
  }
}

class HomeScreeAbovePart extends StatelessWidget {
  final bool loading;
  HomeScreeAbovePart(this.loading);
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SpinKitFadingCircle(
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.red : Colors.green,
            ),
          );
        },
      );
    } else {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[HomeScreeTopPart(), HomeScreenBottomPart()],
          ),
        ),
      );
    }
  }
}

class HomeScreeTopPart extends StatelessWidget {
  HomeScreeTopPart();

  @override
  Widget build(BuildContext context) {
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
                      Cache.appData.streammer.activeStreaming.thumbnail.url,
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
                            Cache.appData.streammer.activeStreaming.title,
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
                        arguments: Cache.appData.streammer.activeStreaming,
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
                            child: Icon(Cache.appData.streammer.videoIcon,
                                size: 30.0, color: Color(0xFFe2d504)),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Text(
                            Cache.appData.streammer
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

class HomeScreenBottomPart extends StatefulWidget {
  HomeScreenBottomPart();

  @override
  _HomeScreenBottomPartState createState() => _HomeScreenBottomPartState();
}

class _HomeScreenBottomPartState extends State<HomeScreenBottomPart> {
  static String key =
      "AIzaSyBJffXixRGSguaXNQxbtZb_am90NI9nGHg"; // ** ENTER YOUTUBE API KEY HERE **

  //YoutubeAPI ytApi = new YoutubeAPI(key, type: "playlist");
  //List<YT_API> ytResult = [];

  /*callAPI() async {
      print('UI callled');
      String query = "Entrenamientos Infantiles";
      ytResult = await ytApi.search(query);
      print("length ======= ${ytResult.length}");
      print("ytResult channelurl ========= ${ytResult[0].channelurl}");
      print("ytResult channelTitle ========= ${ytResult[0]}");

      print("ytResult channelurl ========= ${ytResult[1].channelurl}");
      print("ytResult channelTitle ========= ${ytResult[1].channelTitle}");

      print("ytResult channelurl ========= ${ytResult[2].channelurl}");
      print("ytResult channelTitle ========= ${ytResult[2].channelTitle}");

      print("ytResult channelurl ========= ${ytResult[3].channelurl}");
      print("ytResult channelTitle ========= ${ytResult[3].channelTitle}");
    }*/

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
                    Cache.appData.streammer.streamings[i].thumbnail.url,
                    width: double.infinity,
                    height: 130.0,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0),
                  child: Text(Cache.appData.streammer.streamings[i].title,
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
  void initState() {
    //callAPI();
    super.initState();
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
