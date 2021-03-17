import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/business/cache.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:curupas/models/HTML.dart';
import 'package:curupas/models/add_media.dart';
import 'package:curupas/ui/widgets/anectodes.dart';
import 'package:curupas/ui/widgets/giras/giras_widget.dart';
import 'package:curupas/ui/widgets/staggered.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
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

    if (_globals.group_data_loaded == false) {
      loadGroupData();
      _globals.eventBus.on().listen((event) {
        String _event = event.toString();
        if (_event.contains("group")) {
          _counting = _counting + 1;
          if (_counting == 3) {
            _counting = 0;
            if (mounted) {
              loaded();
            } else {
              Timer.periodic(Duration(seconds: 5), (timer) {
                if (mounted) {
                  loaded();
                  timer.cancel();
                }
                print("Home timer 5 seconds call mountedf");
              });
            }
          }
          print("Counting : ${_counting}");
        }
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  void loadGroupData() async {
    setState(() {
      _loading = true;
    });
    _globals.getGroupVideoMedia();
    _globals.getAnecdotes();
    _globals.getGiras();
  }

  void loaded() {
    _globals.group_data_loaded = true;
    setState(() {
      _loading = false;
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
                .getImagePath(FileType.media)
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
                    rotateButtonsHidden: true,
                    resetButtonHidden: true,
                    aspectRatioPickerButtonHidden: true,
                    resetAspectRatioEnabled: true,
                  ));
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
    double bottomPadding = _statusBarHeight + ScreenUtil().setHeight(30.0);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Container(
              child: Image.asset(
                Cache.appData.group_background,
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
                    //AnecdoteSection(loading),
                    //GirasSection(loading),
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
            GirasSection(loading),
            AnecdoteSection(loading),
            StaggeredWidget(_height)
          ],
        ),
      ),
    );
  }
}

class AnecdoteSection extends StatelessWidget {
  final bool loading;

  AnecdoteSection(this.loading);

  @override
  Widget build(BuildContext context) {
    List<HTML> anecdotes = Cache.appData.anecdoteContent.contents;

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

class GirasSection extends StatelessWidget {
  final bool loading;

  GirasSection(this.loading);

  @override
  Widget build(BuildContext context) {
    List<HTML> giras = Cache.appData.girasContent.contents;

    double width = MediaQuery.of(context).size.width;

    Size _size = new Size(width, 150);

    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
      child: SizedBox.fromSize(
        size: _size,
        child: new GirasWidget(giras: giras),
      ),
    );
  }
}
