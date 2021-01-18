import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/models/HTML.dart';
import 'package:curupas/models/add_media.dart';
import 'package:curupas/ui/widgets/anecdote/anecdote_widget.dart';
import 'package:curupas/ui/widgets/anectodes.dart';
import 'package:curupas/ui/widgets/staggered.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_cropper/image_cropper.dart';
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

  bool _loading = true;
  int _counting = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GroupStream(_loading),
      floatingActionButton: buildSpeedDial(context),
    );
  }

  @override
  void initState() {
    super.initState();

    _globals.getGroupVideoMedia();
    _globals.getAnecdotes();

    _globals.eventBus.on().listen((event) {
      String _event = event.toString();
      if (_event.contains("group")) {
        _counting = _counting + 1;
        if (_counting == 2) {
          _globals.setDataFromGlobal();
          _counting = 0;
          setState(() {
            _loading = false;
          });
        }
        print("Counting : ${_counting}");
      }
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
                .getImagePath(FileType.image)
                .then((result) async {

                  //File _file = new File(result);

              File croppedFile = await ImageCropper.cropImage(
                  sourcePath: result,
                  aspectRatioPresets: [
                    CropAspectRatioPreset.square,
                    //CropAspectRatioPreset.ratio3x2,
                    //CropAspectRatioPreset.original,
                    //CropAspectRatioPreset.ratio4x3,
                    //CropAspectRatioPreset.ratio16x9
                  ],
                  androidUiSettings: AndroidUiSettings(
                      toolbarTitle: 'Recortar imagen',
                      toolbarColor: Colors.blue,
                      toolbarWidgetColor: Colors.white,
                      initAspectRatio: CropAspectRatioPreset.square,
                      lockAspectRatio: true,
                      hideBottomControls: true),
                  iosUiSettings: IOSUiSettings(
                    minimumAspectRatio: 1.0,
                    rotateButtonsHidden:true,
                    resetButtonHidden:true,
                    aspectRatioPickerButtonHidden:true,
                    resetAspectRatioEnabled:true,
                  )
              );
              Image _newImage = new Image.file(croppedFile);

              if (_newImage != null) {

                _imagePath = result;
                //Image _newImage = new Image.file(_file);

                AddMedia addMedia = new AddMedia(
                    title: "Imagen seleccionada",
                    selectedImage: _newImage,
                    path: _imagePath,
                    type: "images",
                    typeId: 2);

                Navigator.pushNamed(
                  context,
                  '/addmedia',
                  arguments: addMedia,
                );
              }
              ;
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
                .getImagePath(FileType.video)
                .then((result) {
              File _file = new File(result);
              if (_file != null) {
                _videoPath = result;
                _globals.filePickerGlobal
                    .getThumbnailFromVideo(_videoPath)
                    .then((Image image) async {
                  setState(() {
                    AddMedia addMedia = new AddMedia(
                        title: "Video seleccionado",
                        selectedImage: image,
                        path: result,
                        type: "videos",
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
  final bool loading;

  GroupStream(this.loading);

  @override
  _GroupStreamState createState() => new _GroupStreamState();
}

class _GroupStreamState extends State<GroupStream> {
  @override
  Widget build(BuildContext context) {
//    double height = MediaQuery.of(context).size.height;
//    double _height = height - (80 /* navbar */ + ScreenUtil.statusBarHeight);
    return Scaffold(
      body: Container(child: GroupBackground(widget.loading)),
    );
  }
}

class GroupBackground extends StatelessWidget {
  final bool loading;

  GroupBackground(this.loading);

  @override
  Widget build(BuildContext context) {
    double _statusBarHeight = MediaQuery.of(context).padding.top;
    double bottomPadding =
        _statusBarHeight + ScreenUtil().setHeight(30.0);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Container(
              child: Image.asset(
                _globals.appData.group_background,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  children: <Widget>[
                    UpperSection(loading),
                    _buildContent(context, loading),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      //floatingActionButton: buildSpeedDial(),
    );
  }
}

Widget _buildContent(BuildContext context, bool loading) {
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
    double height = MediaQuery.of(context).size.height;
    double _height = height - 150;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MuseumSection(loading),
            StaggeredWidget(_height)
          ],
        ),
      ),
    );
  }
}

class UpperSection extends StatelessWidget {
  final bool loading;

  UpperSection(this.loading);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: Container(
          child: Image.asset("assets/images/camadas.png",
              height: 45.0, width: 214.0, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// double height = MediaQuery.of(context).size.height;
//      double gridHeight = height - 200;

class MuseumSection extends StatelessWidget {
  final bool loading;

  MuseumSection(this.loading);

  @override
  Widget build(BuildContext context) {
    List<HTML> anecdotes = _globals.anecdoteContent.contents;

    double width = MediaQuery.of(context).size.width;

    Size _size = new Size(width, 150);

    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
      child: SizedBox.fromSize(
        size: _size,
        child: new AnecdotesWidget(anecdotes: anecdotes),
      ),
    );
  }
}

/*class StaggeredSection
        extends StatelessWidget {

      //final _GroupPageState parent;
      //bool verticalGallery = false;

      //StaggeredSection({Key key, @required this.parent}) : super(key: key);

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
    }*/
