
  import 'dart:io';
  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/models/add_media.dart';
  import 'package:curupas/ui/screens/widgets/anecdote/anecdote_widget.dart';
  import 'package:curupas/ui/screens/widgets/gallery/galleryPhotoViewWrapper.dart';
  import 'package:curupas/ui/screens/widgets/gallery/gallery_example_item.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:flutter/gestures.dart';
  import "package:flutter/material.dart";
  import 'package:flutter/cupertino.dart';
  import 'package:flutter_speed_dial/flutter_speed_dial.dart';
  import 'package:curupas/globals.dart' as _globals;
  import 'package:curupas/ui/screens/friend_screen.dart';
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
            children: <Widget>[Container(height: height, child: GroupBody())],
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
                          type:"images");

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
                            type:"videos");

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
            SizedBox(
              height: 8.0,
            ),
            UpperSection(),
            _buildAnecdotes(),
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

  class GridSection extends StatelessWidget {
    final _GroupPageState parent;

    bool verticalGallery = false;

    GridSection({Key key, @required this.parent}) : super(key: key);

    TextStyle defaultStyle = TextStyle(fontSize: 24, color: Colors.grey);
    List<Object> allImage = new List();

    @override
    Widget build(BuildContext context) {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 00.0,
            child: _buildGrid(context),
          ),
        ],
      );
    }

    Widget _buildGrid(BuildContext context) {
      return new Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GalleryExampleItemThumbnail(
                          galleryExampleItem: galleryItems[0],
                          onTap: () {
                            open(context, 0);
                          },
                        ),
                        GalleryExampleItemThumbnail(
                          galleryExampleItem: galleryItems[2],
                          onTap: () {
                            open(context, 2);
                          },
                        ),
                        GalleryExampleItemThumbnail(
                          galleryExampleItem: galleryItems[3],
                          onTap: () {
                            open(context, 3);
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Vertical"),
                        Checkbox(
                          value: verticalGallery,
                          onChanged: (value) {
                            parent.setState(() {
                              verticalGallery = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    void open(BuildContext context, final int index) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryPhotoViewWrapper(
            galleryItems: galleryItems,
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            initialIndex: index,
            scrollDirection: verticalGallery ? Axis.vertical : Axis.horizontal,
          ),
        ),
      );
    }
  }

  Widget _buildAnecdotes() {

    if   (_globals.appData.anecdotes!= null) {


      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SizedBox.fromSize(
          size: Size.fromHeight(200.0),
          child: new AnecdoteWidget(anecdotes: _globals.appData.anecdotes),
        ),
      );

    } else {

      TextStyle messageStyle = TextStyle(fontSize: 24, color: Colors.grey);

      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SizedBox.fromSize(
          size: Size.fromHeight(200.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: messageStyle,
              text:
              "Agrega tus historias entrando en ",
              children: <TextSpan>[
                TextSpan(
                    text:
                    " la pagina "),
                TextSpan(
                    text: 'app.curupas.com.ar',
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        print('You clicked on me!');
                      }),
                TextSpan(
                    text:
                    " desde tu computadora."),
              ],
            ),
          ),
        ),
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
