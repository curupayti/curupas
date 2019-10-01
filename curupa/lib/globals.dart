import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_flow/models/description.dart';
import 'package:onboarding_flow/models/feeds.dart';
import 'package:onboarding_flow/models/group.dart';
import 'package:onboarding_flow/models/user.dart';
import 'package:onboarding_flow/ui/widgets/custom_alert_dialog.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:file_picker/file_picker.dart';
import 'business/auth.dart';
import 'models/streaming.dart';
import 'package:path/path.dart' as p;

User user = new User();
Group group = new Group();
Description description = new Description();
List<Feed> feeds = new List<Feed>();
Data dataFeed;
Streammer streammer;
bool streamingReachable = false;
FilePickerGlobal filePickerGlobal;
//double bottomNavBarHeight = 80;

void getUserData(String userId, bool hasGroup) async {
  if (userId != null) {
    Stream<User> userStream = Auth.getUser(userId);
    userStream.listen((User _user) async {
      Auth.getUserDocumentReference(_user.userID).then((doc) async {
        _user.userRef = doc;
        user = _user;
        if (hasGroup) {
          DocumentReference groupRef = _user.groupRef;
          DocumentSnapshot docsnapshot = await groupRef.get();
          if (docsnapshot.exists) {
            String year = docsnapshot['year'];
            String documentID = docsnapshot.documentID;
            group = new Group(year: year, documentID: documentID);
          }
        }
      });
    });
  }
}

class Streammer {
  List<YT_API> ytResult = [];
  List<Streaming> streamings;
  bool _isLiveStreaming = false;
  IconData videoIcon;
  String showLivestreamingMessage;
  Streaming activeStreaming;

  Streammer() {
    setIsLiveStreaming(false);
  }

  void setIsLiveStreaming(bool _isLive) {
    if (_isLive) {
      showLivestreamingMessage = "Transmisión en vivo";
      videoIcon = Icons.live_tv;
    } else {
      showLivestreamingMessage = "Video ya emitido";
      videoIcon = Icons.tv;
    }
    _isLiveStreaming = _isLive;
  }

  void setYtResutl(List<YT_API> _ytResult) {
    ytResult = _ytResult;
  }

  void serStreamings(List<Streaming> _streamings) {
    activeStreaming = _streamings[0];
    streamings = _streamings;
  }
}

void setFilePickerGlobal() {
  filePickerGlobal = new FilePickerGlobal();
}

void setYoutubeApi(List<YT_API> _ytResult) {
  streammer = new Streammer();
  streammer.setYtResutl(_ytResult);
}

void setDataFeed(String desc, List<Feed> feeds) {
  dataFeed = new Data(
    name: 'Curupa',
    avatar: 'assets/images/escudo.png',
    backdropPhoto: 'assets/images/cancha.png',
    location: 'Hurlingham, Buenos Aires',
    biography: desc,
    feeds: feeds,
  );
}

void showErrorAlert(
    {BuildContext context,
    String title,
    String content,
    VoidCallback onPressed}) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return CustomAlertDialog(
        content: content,
        title: title,
        onPressed: onPressed,
      );
    },
  );
}

class FilePickerGlobal {
  //File Picker
  FileType _pickingType;
  bool _multiPick = false;
  bool _hasValidMime = false;
  String _path;
  String _fileName;
  Map<String, String> _paths;
  String _extension;

  Future<String> getImagePath(/*bool upload*/) async {
    String _path;
    _pickingType = FileType.IMAGE;
    _hasValidMime = true;
    _paths = null;
    _path = await FilePicker.getFilePath(
        type: _pickingType, fileExtension: _extension);
    /*if (upload) {
      await uploadFile(_path).then((url) async {
        return url;
      });
    } else {
      return _path;
    }*/
    return _path;
  }

  Future<String> uploadFile(String _imagePath, String fileName) async {
    String extension = p.extension(_imagePath);
    //Random().nextInt(1000000).toString()
    String fileFolderExtension = fileName + '$extension';
    StorageReference storageRef =
        FirebaseStorage.instance.ref().child(fileFolderExtension);
    StorageUploadTask uploadTask = storageRef.putFile(File(_imagePath));
    StreamSubscription<StorageTaskEvent> streamSubscription =
        uploadTask.events.listen((event) {
      print('EVENT ${event.type}');
    });
    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    String url = (await downloadUrl.ref.getDownloadURL());
    streamSubscription.cancel();
    return url;
  }
}

class Data {
  Data({
    @required this.name,
    @required this.avatar,
    @required this.backdropPhoto,
    @required this.location,
    @required this.biography,
    @required this.feeds,
  });

  final String name;
  final String avatar;
  final String backdropPhoto;
  final String location;
  final String biography;
  final List<Feed> feeds;
}

class Video {
  Video({
    @required this.title,
    @required this.thumbnail,
    @required this.url,
  });

  final String title;
  final String thumbnail;
  final String url;
}
