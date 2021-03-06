import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:curupas/models/curupa_user.dart';
import 'package:curupas/models/description.dart';
import 'package:curupas/models/group.dart';
import 'package:curupas/models/post.dart';
import 'package:curupas/ui/widgets/alert_dialog.dart';
import 'package:event_bus/event_bus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'business/auth.dart';
import 'business/cache.dart';
import 'models/HTMLS.dart';
import 'models/group_media.dart';
import 'models/museum.dart';
import 'models/notification.dart';
import 'models/streammer.dart';

//Events
EventBus eventBus = EventBus();

//APP CONTENT FOR Data
//List<Streaming> streammer = new List<Streaming>();
Streammer streammer = new Streammer();

//HTML CONTENT
//Youtube
String key = "AIzaSyBJffXixRGSguaXNQxbtZb_am90NI9nGHg";
String channelId = "UCeLNPJoPAio9rT2GAdXDVmw";

List<NotificationCloud> notifications = new List<NotificationCloud>();

//bool streamingReachable = false;
FilePickerGlobal filePickerGlobal;
final picker = ImagePicker();
File _image;

String error_email_already_in_use = "ERROR_EMAIL_ALREADY_IN_USE";
String error_unknown = "ERROR_UNKNOWN";

String register_error_title = "Error en el registro";
String signin_error_title = "Error de autentificación";

bool home_data_loaded = false;
bool calendar_data_loaded = false;
bool group_data_loaded = false;

Future<CurupaUser> getUserData(String userId) async {
  CurupaUser _user = new CurupaUser();
  if (userId != null) {
    _user = await Auth.getUser(userId);
    if (_user.yearRef != null) {
      DocumentSnapshot yearSnapshot =
          await Cache.getCacheDocumentByReference(_user.yearRef);
      if (yearSnapshot.exists) {
        try {
          Cache.appData.group = await Group.fromDocument(yearSnapshot);
          _user.group = Cache.appData.group;
          return _user;
        } on Exception catch (exception) {
          print(exception.toString());
        } catch (error) {
          print(error.toString());
        }
      }
    }
  }
  //return _user;
}

class CurupaGuest {
  bool isGuest = false;
  String phone;
  User user_anonymous;
  CurupaUser user;
  void set guest(bool isguest) {
    isGuest = isguest;
  }

  bool get guest => isGuest;
}

void setFilePickerGlobal() {
  filePickerGlobal = new FilePickerGlobal();
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

  Future<String> getImagePath(FileType fileType) async {
    String _pathImage;

    try {
      //_pickingType = fileType; //FileType.IMAGE;
      //_hasValidMime = true;
      //_paths = null;

      /*FilePickerResult result = await FilePicker.platform.pickFiles(
            //type: fileType,
            type: FileType.custom,
            allowedExtensions: ['jpg', 'pdf', 'doc'],//['jpg', 'png'],
          );*/

      //FilePickerResult result = await FilePicker.platform.pickFiles();

      //_path = await FilePicker.getFilePath(
      //type: _pickingType); //, fileExtension: _extension);

      /*if (upload) {
                await uploadFile(_path).then((url) async {
                  return url;
                });
              } else {
                return _path;
              }*/

      final pickedFile = await picker.getImage(source: ImageSource.camera);

      if (pickedFile != null) {
        _image = File(pickedFile.path);

        //_path = pickedFile.path;

        _pathImage = _image.path;

        //PlatformFile file = result.files.single;

        //File file = File(result.files.single.path);

        //_path = file.path;

        /*print(file.name);
            print(file.bytes);
            print(file.size);
            print(file.extension);
            print(file.path);*/

      } else {
        // User canceled the picker
      }
    } catch (err) {
      print('Caught error: $err');
    }

    return _pathImage;
  }

  Future<Image> getThumbnailFromVideo(String path) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 300,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    return new Image.memory(uint8list);
  }

  Future<bool> uploadFile(
      String _imagePath, String filePath, SettableMetadata metadata,
      {File file}) async {
    FirebaseStorage storageInstance = FirebaseStorage.instance;

    if (_imagePath == "" || _imagePath == null || _imagePath.isEmpty) {
      String fileFolderExtension = filePath + 'profile.jpeg';

      Reference storageRef = storageInstance.ref().child(fileFolderExtension);
      UploadTask uploadTask = storageRef.putFile(file, metadata);

      await uploadTask.whenComplete(() => {
            //String url = (await downloadUrl.ref.getDownloadURL());
            //streamSubscription.cancel();
          });
    } else {
      String extension = p.extension(_imagePath);
      //String fileFolderExtension = folder + "/" +  fileName + '$extension';

      String fileFolderExtension = filePath + '$extension';

      Reference storageRef = storageInstance.ref().child(fileFolderExtension);
      UploadTask uploadTask = storageRef.putFile(File(_imagePath), metadata);

      await uploadTask.whenComplete(() => {
            //String url = (await downloadUrl.ref.getDownloadURL());
            //streamSubscription.cancel();
          });
    }
  }

  Future<String> getStorageFileUrl(String childReference) async {
    Reference storageRef = FirebaseStorage.instance.ref().child(childReference);
    String url = await storageRef.getDownloadURL();

    return url;
  }
}

void launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
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

Future<bool> sendUserSMSVerification(
    String phone, String message, String userId, int smsCode) async {
  try {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('sendSMS');
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

//MAIN

void getDrawers() async {
  if (Cache.appData.drawerContent == null) {
    HTMLS _pumasContent = await Auth.getHtmlContentByType("drawer");
    Cache.appData.drawerContent = _pumasContent;
    Cache.appData.drawerContent.contents.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }
  eventBus.fire("main-drawer");
}

//HOME

void getNewsletters() async {
  if (Cache.appData.newsletterContent == null) {
    HTMLS _newsletterContent = await Auth.getHtmlContentByType("newsletter");
    Cache.appData.newsletterContent = _newsletterContent;
    Cache.appData.newsletterContent.contents.sort((a, b) {
      return a.last_update.compareTo(b.last_update);
    });
  }
  eventBus.fire("home-newsletter");
}

void getMuseums() async {
  if (Cache.appData.museums == null) {
    List<DocumentSnapshot> templist = await Auth.getMuseumSnapshots();
    List<Museum> _museums = await Auth.getMuseum(templist);
    Cache.appData.museums = _museums;
  }
  eventBus.fire("home-museum");
}

void getPumas() async {
  if (Cache.appData.pumasContent == null) {
    HTMLS _pumasContent = await Auth.getHtmlContentByType("pumas");
    Cache.appData.pumasContent = _pumasContent;
    Cache.appData.pumasContent.contents.sort((a, b) {
      return a.last_update.compareTo(b.last_update);
    });
  }
  eventBus.fire("home-pumas");
}

void getValores() async {
  if (Cache.appData.valoresContent == null) {
    HTMLS _valoresContent = await Auth.getHtmlContentByType("valores");
    Cache.appData.valoresContent = _valoresContent;
    Cache.appData.valoresContent.contents.sort((a, b) {
      return a.last_update.compareTo(b.last_update);
    });
  }
  eventBus.fire("home-valores");
}

Future<Description> getDescription() async {
  Description _desc;
  if (Cache.appData.description == null) {
    _desc = await Auth.getDescription();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    _desc.appName = appName;
    _desc.packageName = packageName;
    _desc.version = version;
    _desc.buildNumber = buildNumber;
    Cache.appData.description = _desc;
  } else {
    _desc = Cache.appData.description;
  }
  eventBus.fire("home-description");
  return _desc;
}

void getPosts() async {
  if (Cache.appData.posts == null) {
    List<DocumentSnapshot> templist = await Auth.getPostSnapshots();
    List<Post> _posts = await Auth.getPost(templist);
    Cache.appData.posts = _posts;
  }
  eventBus.fire("home-posts");
}

//CALENDAR
Future<QuerySnapshot> getCalendar(String name) async {
  QuerySnapshot querySnapshot;
  await Auth.getCalendarData(name).then((snapshot) {
    querySnapshot = snapshot;
  });
  return querySnapshot;
}

Future<QuerySnapshot> getCalendarEvents(DateTime dateTime, String name) {
  Auth.getCalendarEvents(dateTime, name).then((snapshot) {
    //_userEventSnapshot = snapshot;
    eventBus.fire("calendar-event");
    return snapshot;
  });
}

//GROUP

void getGroupVideoMedia() {
  String groupId = Cache.appData.group.documentID;
  Auth.getGroupVideoMediaByType(groupId)
      .then((List<GroupMedia> listGroupMedia) {
    Cache.appData.group.medias = listGroupMedia;
    eventBus.fire("group-media");
  });
}

void getAnecdotes() async {
  HTMLS _anecdote = await Auth.getHtmlContentByTypeAndGroup(
      "anecdote", Cache.appData.group.yearRef);
  Cache.appData.anecdoteContent = _anecdote;
  Cache.appData.anecdoteContent.contents.sort((a, b) {
    return a.last_update.compareTo(b.last_update);
  });
  eventBus.fire("group-anecdotes");
}

void getNotifications() async {
  Auth.getNotifications().then((data) {
    notifications = data;
    notifications.sort((a, b) {
      return a.last_update.compareTo(b.last_update);
    });
    eventBus.fire("profile-notifications");
  });
}

//MEDIA
void getMedia() {
  Auth.getStreaming().then((_streamings) {
    streammer.serStreamings(_streamings);
    eventBus.fire("home-streamings");
  });
}

Future<File> writeYoutubeLog(int counter, String content) async {
  final file = await _localFile;
  // Write the file.
  return file.writeAsString('$content');
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/log_youtube.txt');
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

void showToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
