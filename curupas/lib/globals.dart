import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:curupas/models/description.dart';
import 'package:curupas/models/post.dart';
import 'package:curupas/models/group.dart';
import 'package:curupas/models/user.dart';
import 'package:curupas/ui/screens/widgets/alert_dialog.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:file_picker/file_picker.dart';
import 'business/auth.dart';
import 'models/streaming.dart';
import 'package:path/path.dart' as p;
import 'dart:math' as math;

User user = new User();
Group group = new Group();
Description description = new Description();
List<Post> feeds = new List<Post>();
Data dataPost = new Data();
Streammer streammer;
bool streamingReachable = false;
FilePickerGlobal filePickerGlobal;
//double bottomNavBarHeight = 80;

String error_email_already_in_use = "ERROR_EMAIL_ALREADY_IN_USE";
String error_unknown = "ERROR_UNKNOWN";

String register_error_title = "Error en el registro";
String signin_error_title = "Error de autentificación";

Future<User> getUserData(String userId) async {
  if (userId != null) {
    User user = new User();
    await Auth.getUserDocumentReference(userId)
        .then((userDocumentReference) async {
      await userDocumentReference.get().then((userSnapshot) async {
        if (userSnapshot.exists) {
          DocumentReference yearDocumentReference =
              userSnapshot.data["yearRef"];
          if (yearDocumentReference != null) {
            await yearDocumentReference.get().then((yearSnapshot) async {
              if (yearSnapshot.exists) {
                user.userRef = userDocumentReference;
                try {
                  group = await Group.fromDocument(yearSnapshot);
                  userSnapshot.data["group"] = group;
                  user = await User.fromDocument(userSnapshot);
                  return user;
                } on Exception catch (exception) {
                  print(exception.toString());
                } catch (error) {
                  print(error.toString());
                }
              }
            });
          } else {
            user = await User.fromDocument(userSnapshot);
            return user;
          }
        }
      });
    });
    return user;
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

void setDataPosts(String desc, List<Post> posts) {
  Data _dataPost = new Data(
    name: 'Curupa',
    avatar: 'assets/images/escudo.png',
    backdropPhoto: 'assets/images/cancha.png',
    location: 'Hurlingham, Buenos Aires',
    biography: desc,
    posts: posts,
  );
  dataPost = _dataPost;
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

  Future<String> uploadFile(
      String _imagePath, String fileName, StorageMetadata metadata) async {
    String extension = p.extension(_imagePath);
    String fileFolderExtension = fileName + '$extension';
    StorageReference storageRef =
        FirebaseStorage.instance.ref().child(fileFolderExtension);
    StorageUploadTask uploadTask =
        storageRef.putFile(File(_imagePath), metadata);
    StreamSubscription<StorageTaskEvent> streamSubscription =
        uploadTask.events.listen((event) {
      print('EVENT ${event.type}');
    });
    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    String url = (await downloadUrl.ref.getDownloadURL());
    streamSubscription.cancel();
    return url;
  }

  Future<String> getStorageFileUrl(String childReference) async {
    StorageReference storageRef =
        FirebaseStorage.instance.ref().child(childReference);
    String url = await storageRef.getDownloadURL();

    return url;
  }
}

class Data {
  Data({
    this.name,
    this.avatar,
    this.backdropPhoto,
    this.location,
    this.biography,
    this.posts,
  });

  final String name;
  final String avatar;
  final String backdropPhoto;
  final String location;
  final String biography;
  final List<Post> posts;
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

Future<int> generateRandom() {
  int resutl = 0;
  var rnd = new math.Random();
  var next = rnd.nextDouble() * 1000;
  while (next < 1000) {
    next *= 10;
  }
  resutl = next.toInt();
  return Future.value(resutl);
}

String getCodeMessgae(int code) {
  String allcode = "Curupas ${code} - http://noti.ms";
  /*String allcode;
  allcode = "| Curupas |\r\n";
  allcode += "|  ${code}  |\r\n";
  allcode += "| noti.ms |";
  int length = allcode.length;*/
  print(allcode);
  return allcode;
}

void sendUserSMSVerification(
    String phone, String message, String userId, int smsCode) async {
  try {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'sendSMS',
    );
    HttpsCallableResult resp = await callable.call(<String, dynamic>{
      "phone": phone,
      "payload": message,
      "userId": userId,
      "smsCode": smsCode
    });
    print(resp.toString());
  } catch (e) {
    print('caught generic exception');
    print(e);
  }
}
