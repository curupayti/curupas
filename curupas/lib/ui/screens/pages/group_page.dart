
  import 'dart:io';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:curupas/models/add_media.dart';
  import 'package:curupas/ui/screens/widgets/anecdote/anecdote_widget.dart';
  import 'package:curupas/ui/screens/widgets/anectodes.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:flutter/gestures.dart';
  import "package:flutter/material.dart";
  import 'package:flutter/cupertino.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:flutter_speed_dial/flutter_speed_dial.dart';
  import 'package:curupas/globals.dart' as _globals;
  import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'dart:ui' as ui;

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
    List<Color> _colors = [Colors.greenAccent, Colors.yellow];
    List<double> _stops = [0.0, 0.7];
    //File vars
    String _imagePath;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: GroupStream(),
        floatingActionButton: buildSpeedDial(context),
      );
    }

    @override
    void initState() {
      super.initState();

      _globals.eventBus
          .on()
          .listen((event) {
        //print(event.toString());
        setState(() {});
      });
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

  class GroupStream extends StatefulWidget {
    @override
    _GroupStreamState createState() => new _GroupStreamState();
  }

  class _GroupStreamState extends State<GroupStream> {
    @override
    Widget build(BuildContext context) {
      double height = MediaQuery.of(context).size.height;
      double _height = height - (80 /* navbar */ + ScreenUtil.statusBarHeight);
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(height: _height, child: GroupBackground())
            ],
          ),
        ),
      );
    }
  }

  class GroupBackground extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      double bottomPadding =
          ScreenUtil.statusBarHeight + ScreenUtil().setHeight(30.0);
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child:
              Image.asset(_globals.appData.group_background, fit: BoxFit.cover),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: _buildContent(),
                ),
              ),
            ),
            CustomPaint(
              //painter: CurvePainter(0, null, 10),
            ),
            CustomPaint(
              //painter: CurvePainter(null, bottomPadding, 5),
            ),
          ],
        ),
        //floatingActionButton: buildSpeedDial(),
      );
    }
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          UpperSection(),
          //AnecdoteSection(),
          _buildMuseumTimeline(),
          StaggeredSection(),
        ],
      ),
    );
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
                height: 30.0,
              ),
              new Image.asset("assets/images/camadas.png",
                  height: 45.0, width: 214.0, fit: BoxFit.cover),
            ],
          ),
        ]);
    }
  }

  Widget _buildMuseumTimeline() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox.fromSize(
        size: Size.fromHeight(170.0),
        child: new AnecdotesWidget(anecdotes: _globals.appData.anecdotes),
      ),
    );
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
