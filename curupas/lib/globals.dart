import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'business/auth.dart';
import 'business/cache.dart';
import 'models/HTMLS.dart';
import 'models/category.dart';
import 'models/curupa_user.dart';
import 'models/group_media.dart';
import 'models/museum.dart';
import 'models/streaming.dart';
import 'models/streaming_video.dart';

//Events
EventBus eventBus = EventBus();

//HTML CONTENT
//Youtube
String key = "AIzaSyBJffXixRGSguaXNQxbtZb_am90NI9nGHg";
String channelId = "UCeLNPJoPAio9rT2GAdXDVmw";

//bool streamingReachable = false;
FilePickerGlobal filePickerGlobal;
final picker = ImagePicker();
File _image;

SharedPreferences prefs;

String error_email_already_in_use = "ERROR_EMAIL_ALREADY_IN_USE";
String error_unknown = "ERROR_UNKNOWN";

String register_error_title = "Error en el registro";
String signin_error_title = "Error de autentificación";

bool user_data_loaded = false;
bool drawer_data_loaded = false;
bool years_data_loaded = false;
bool categories_data_loaded = false;

bool home_data_loaded = false;
bool calendar_data_loaded = false;
bool streaming_data_loaded = false;
bool group_data_loaded = false;
bool notification_data_loaded = false;

String calendar_active_button = "calendar_active_button";

Future<CurupaUser> getUserData(String userId) async {
  CurupaUser _user = new CurupaUser();
  try {
    //prefs = await SharedPreferences.getInstance();
    //bool force = prefs.getBool(force_update_user);
    //prefs.setBool(force_update_user, false);
    //if (force) {
    //if (userId != null) {
    //_user = await Auth.getUser(userId);
    //_user = await getGroupData(_user);
    //}
    //} else
    if ((Cache.appData.user.userID == null) ||
        (Cache.appData.user.isRegistering)) {
      if (userId != null) {
        _user = await Auth.getUser(userId);
        _user = await getGroupData(_user);
      }
    } else {
      _user = await getGroupData(Cache.appData.user);
    }
  } catch (error) {
    print(error);
  }
  eventBus.fire("main-user");
  return _user;
}

Future<CurupaUser> getGroupData(CurupaUser _user) async {
  if (_user.yearRefs != null) {
    DocumentSnapshot yearSnapshot =
        await Cache.getCacheDocumentByReference(_user.yearRefs[0]);
    if (yearSnapshot.exists) {
      try {
        Cache.appData.group = await Group.fromDocument(yearSnapshot);
        _user.group = Cache.appData.group;
        eventBus.fire("profile-user");
        return _user;
      } on Exception catch (exception) {
        print(exception.toString());
      } catch (error) {
        print(error.toString());
      }
    }
  }
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

Future<void> loadUpdates() async {
  prefs = await SharedPreferences.getInstance();
  return await Auth.getUpdates();
}

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
Future<QuerySnapshot> getCalendar(String name, int id) async {
  QuerySnapshot querySnapshot;
  String path;
  if (id == 3) {
    path =
        "calendar/${name}/${Cache.appData.user.category.documentID}_collection";
  } else {
    path = "calendar/${name}/${name}_collection";
  }
  await Auth.getCalendarData(path).then((snapshot) {
    querySnapshot = snapshot;
  });
  return querySnapshot;
}

Future<QuerySnapshot> getCalendarEvents(
    DateTime dateTime, String name, int id) {
  Auth.getCalendarEvents(dateTime, name).then((snapshot) {
    //_userEventSnapshot = snapshot;
    eventBus.fire("calendar-event");
    return snapshot;
  });
}

//CATEGORIES

//Future<List<DropdownMenuItem<String>>> getCategoryList() async {
Future<List<Category>> getCategoryList() async {
  //List<DropdownMenuItem<String>> items = [];
  QuerySnapshot querySnapshot =
      await Cache.getCacheCollectionByPath("categories");
  //items.add(new DropdownMenuItem(value: null, child: new Text("----")));
  List<Category> categories = [];
  for (var doc in querySnapshot.docs) {
    String category = doc.id; //['year'];
    String documentID = doc.id;
    DocumentReference catRef =
        FirebaseFirestore.instance.collection('categorias').doc(category);
    categories.add(new Category(
        category: category, documentID: documentID, categoryRef: catRef));
    //items.add(
    //    new DropdownMenuItem(value: documentID, child: new Text(category)));
  }
  Cache.appData.categories = categories;
  //print(items.length);
  return categories;
}

//Future<List<DropdownMenuItem<String>>> getGroupsList() async {
Future<List<Group>> getGroupsList() async {
  //List<DropdownMenuItem<String>> items = [];
  QuerySnapshot querySnapshot = await Cache.getCacheCollectionByPath("years");
  //items.add(new DropdownMenuItem(value: null, child: new Text("----")));
  List<Group> groups = [];
  for (var doc in querySnapshot.docs) {
    String year = doc['year'];
    String documentID = doc.id;
    if ((year != "invitado") && (year != "admin")) {
      DocumentReference groupRef =
          FirebaseFirestore.instance.collection('years').doc(doc.reference.id);
      groups.add(new Group(
          year: year,
          documentID: documentID,
          yearRef: groupRef)); //doc.reference));
      //items.add(
      //    new DropdownMenuItem(value: documentID, child: new Text(year)));
    }
  }
  //print(items.length);
  return groups;
}

//GROUP

void getGroupVideoMedia() async {
  if (Cache.appData.group.medias == null) {
    String groupId = Cache.appData.group.documentID;
    List<GroupMedia> listGroupMedia =
        await Auth.getGroupVideoMediaByType(groupId);
    Cache.appData.group.medias = listGroupMedia;
  }
  eventBus.fire("group-media");
}

void getAnecdotes() async {
  if (Cache.appData.anecdoteContent == null) {
    HTMLS _anecdoteContent = await Auth.getHtmlContentByType("anecdote");
    Cache.appData.anecdoteContent = _anecdoteContent;
    Cache.appData.anecdoteContent.contents.sort((a, b) {
      return a.last_update.compareTo(b.last_update);
    });
  }
  eventBus.fire("group-anecdotes");
}

void getGiras() async {
  if (Cache.appData.girasContent == null) {
    HTMLS _girasContent = await Auth.getHtmlContentByType("giras");
    Cache.appData.girasContent = _girasContent;
    Cache.appData.girasContent.contents.sort((a, b) {
      return a.last_update.compareTo(b.last_update);
    });
  }
  eventBus.fire("group-giras");
}

void getNotifications() async {
  if (Cache.appData.notifications == null) {
    await Auth.getNotifications().then((data) {
      Cache.appData.notifications = data;
      Cache.appData.notifications.sort((a, b) {
        return a.last_update.compareTo(b.last_update);
      });
    });
  }
  eventBus.fire("profile-notifications");
}

//MEDIA
void getStreamingCollected() async {
  try {
    List<Streaming> _streamings = await Auth.getStreaming();
    for (var i = 0; i < _streamings.length; i++) {
      Streaming streaming = _streamings[i];
      var playListId = streaming.playListId;
      List<StreamingVideo> streamingvideos =
          await Auth.getStreamingVideosById(playListId);
      //Cache.appData.streammer.streamings[i].videos = streamingvideos;
      streaming.videos = streamingvideos;
      Cache.appData.streammer.streamings.add(streaming);
    }
    Cache.appData.streammer.serStreamings(Cache.appData.streammer.streamings);
    eventBus.fire("home-streamings");
  } on Exception catch (error) {
    print("Error: " + error.toString());
  }
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
