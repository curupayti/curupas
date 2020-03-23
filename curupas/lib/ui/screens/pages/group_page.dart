
  import 'dart:io';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:curupas/models/add_media.dart';
  import 'package:curupas/ui/screens/widgets/anecdote/anecdote_widget.dart';
  import 'package:curupas/ui/screens/widgets/flat_button.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:flutter/gestures.dart';
  import "package:flutter/material.dart";
  import 'package:flutter/cupertino.dart';
  import 'package:flutter_speed_dial/flutter_speed_dial.dart';
  import 'package:curupas/globals.dart' as _globals;
  import 'package:curupas/ui/screens/friend_screen.dart';
  import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  class GroupPage extends StatefulWidget {

    GroupPage({Key key}) : super(key: key);
    @override
    _GroupPageState createState() => _GroupPageState();
  }

  class _GroupPageState extends State<GroupPage> {

    var currentUserEmail;

    DocumentReference userRef;
    SharedPreferences prefs;

    String _videoPath;

    double _progressValue;

    //File vars
    String _imagePath;

    @override
    Widget build(BuildContext context) {
      double height = MediaQuery.of(context).size.height;
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  height: height,
                  child: GroupBody()
            )],
          ),
        ),
        floatingActionButton: buildSpeedDial(context),
      );
    }

    @override
    void initState() {
      super.initState();

      getPrefs();
      _progressValue = 0.0;

      //getFirePadFromRef("ZAvWQjFab2fiv27g3Hu0kcpSCXP2");

      _globals.eventBus
          .on()
          .listen((event) {
            //print(event.toString());
            setState(() {});
      });
    }

    void getPrefs() async {
      prefs = await SharedPreferences.getInstance();
    }

    SpeedDial buildSpeedDial(BuildContext context) {
      return SpeedDial(
        marginRight: 25,
        marginBottom: 50,
        animatedIcon: AnimatedIcons.menu_close,
        //animatedIconTheme: IconThemeData(size: 22.0),
        child: Icon(Icons.add),
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Menu',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(Icons.photo, color: Colors.white),
            backgroundColor: Color.fromRGBO(0, 29, 126, 1),
            label: 'Subir imagen',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              _globals.filePickerGlobal
                  .getImagePath(FileType.IMAGE)
                  .then((result) {
                    File _file = new File(result);
                    if (_file != null) {
                      _imagePath = result;
                      Image _newImage = new Image.file(_file);

                      AddMedia addMedia = new AddMedia(
                          title:"Imagen seleccionada",
                          selectedImage :_newImage,
                          path: _imagePath,
                          type:"images",
                          typeId: 2);

                      Navigator.pushNamed(
                        context,
                        '/addmedia',
                        arguments: addMedia,
                      );
                    };
                  });
              },
          ),
          SpeedDialChild(
            child: Icon(Icons.video_label, color: Colors.white),
            backgroundColor: Color.fromRGBO(0, 29, 126, 1),
            label: 'Subir Video',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              _globals.filePickerGlobal
                  .getImagePath(FileType.VIDEO)
                  .then((result) {
                File _file = new File(result);
                if (_file != null) {
                  _videoPath = result;
                  _globals.filePickerGlobal
                      .getThumbnailFromVideo(_videoPath)
                      .then((Image image) async {
                    setState(() {
                        AddMedia addMedia = new AddMedia(
                            title:"Video seleccionado",
                            selectedImage :image,
                            path: result,
                            type:"videos",
                            typeId: 1);
                        Navigator.pushNamed(
                          context,
                          '/addmedia',
                          arguments: addMedia,
                        );
                    });
                  });
                }
              });
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.calendar_today),
            backgroundColor: Colors.white,
            label: 'Proponer juntada',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              //
            },
          ),
        ],
      );
    }
  }


  class GroupBody extends StatelessWidget {
    final _GroupPageState groupPageState;

    GroupBody({Key key, @required this.groupPageState}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          children: <Widget>[
            UpperSection(),
            AnecdoteSection(),
            StaggeredSection(),
            //GridSection(parent: groupPageState),
            //MiddleSection(),
          ],
        ),
      );
    }

    @override
    void initState() {

    }
  }

  class UpperSection extends StatelessWidget {
    const UpperSection({
      Key key,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return new Stack(fit: StackFit.loose, children: <Widget>[
          new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 8.0,
              ),
              new Image.asset("assets/images/camadas.png",
                  height: 45.0, width: 214.0, fit: BoxFit.cover),
              SizedBox(width: 20.0),
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
          ),
        ]);
    }
  }

  class AnecdoteSection extends StatelessWidget {

    final _GroupPageState parent;

    bool verticalGallery = false;

    AnecdoteSection({Key key, @required this.parent}) : super(key: key);

    List<Object> allImage = new List();

    @override
    Widget build(BuildContext context) {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 100.0,
            child: _buildAnecdotes(),
          ),
        ],
      );
    }

    Widget _buildAnecdotes() {

      if   (_globals.appData.anecdotes!= null) {

        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: SizedBox.fromSize(
            size: Size.fromHeight(100.0),
            child: new AnecdoteWidget(anecdotes: _globals.appData.anecdotes),
          ),
        );

      } else {

        TextStyle messageStyle = TextStyle(fontSize: 18, color: Colors.grey);

        return Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: SizedBox.fromSize(
            size: Size.fromHeight(100.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: messageStyle,
                text:
                "Agrega historia ",
                children: <TextSpan>[
                  TextSpan(
                      text: 'app.curupas.com.ar',
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print('You clicked on me!');
                      }
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

  }

  class StaggeredSection extends StatelessWidget {

    final _GroupPageState parent;

    bool verticalGallery = false;

    StaggeredSection({Key key, @required this.parent}) : super(key: key);

    @override
    Widget build(BuildContext context) {

      double height = MediaQuery.of(context).size.height;
      double gridHeight = height - 200;

      return Column(
        children: <Widget>[
          SizedBox(
            height: gridHeight,
            child: StaggeredGridView.countBuilder(
              padding:
              const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0, bottom: 8.0),
              crossAxisCount: 4,
              itemCount: _globals.group.medias.length,
              itemBuilder: (context, j) {
                bool isVideo = false;
                String imgPath = _globals.group.medias[j].thumbnailUrl;
                String title = _globals.group.medias[j].title;
                String description = _globals.group.medias[j].description;
                if (_globals.group.medias[j].type == 1) {
                  isVideo = true;
                }
                return new Card(
                  child: new Column(
                    children: <Widget>[
                      new Center(
                        child:
                        Stack(
                            children: <Widget>[
                              new Image.network(imgPath),
                              Visibility(
                                visible: isVideo,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.play_circle_outline,
                                    size: 60.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: new Column(
                          children: <Widget>[
                            new Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            new Text(
                              description,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
              staggeredTileBuilder: (j) =>
              new StaggeredTile.fit(2),
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
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
