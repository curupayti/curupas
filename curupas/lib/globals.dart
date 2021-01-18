    import 'dart:async';
    import 'dart:io';
    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:cloud_functions/cloud_functions.dart';
    import 'package:diacritic/diacritic.dart';
    import 'package:event_bus/event_bus.dart';
    import 'package:file_picker/file_picker.dart';
    import 'package:firebase_auth/firebase_auth.dart';
    import 'package:firebase_storage/firebase_storage.dart';
    import 'package:flutter/cupertino.dart';
    import 'package:flutter/material.dart';
    import 'package:curupas/models/description.dart';
    import 'package:curupas/models/post.dart';
    import 'package:curupas/models/group.dart';
    import 'package:curupas/models/curupa_user.dart';
    import 'package:curupas/ui/widgets/alert_dialog.dart';
    import 'package:fluttertoast/fluttertoast.dart';
    import 'package:location/location.dart';
    import 'package:shared_preferences/shared_preferences.dart';
    import 'package:url_launcher/url_launcher.dart';
    import 'package:video_thumbnail/video_thumbnail.dart';
    import 'business/auth.dart';
    import 'models/HTML.dart';
    import 'models/HTMLS.dart';
    import 'models/group_media.dart';
    import 'models/museum.dart';
    import 'models/notification.dart';
    import 'models/pumas.dart';
    import 'models/streaming.dart';
    import 'package:path/path.dart' as p;
    import 'dart:math' as math;
    import 'package:path_provider/path_provider.dart';

    import 'models/streammer.dart';

    CurupaUser user = new CurupaUser();
    CurupaGuest curupaGuest = new CurupaGuest();
    Group group = new Group();

    //Events
    EventBus eventBus = EventBus();

    //App Data object
    AppData appData = new AppData();

    //APP CONTENT FOR Data
    Description description = new Description();
    List<Post> posts = new List<Post>();
    List<Museum> museums = new List<Museum>();
    List<Pumas> pumas = new List<Pumas>();
    //List<Streaming> streammer = new List<Streaming>();

    Streammer streammer = new Streammer();

    //HTML CONTENT
    HTMLS drawerContent = new HTMLS();
    HTMLS newsletterContent = new HTMLS();
    HTMLS anecdoteContent = new HTMLS();
    HTMLS pumasContent = new HTMLS();
    HTMLS valoresContent = new HTMLS(); //Youtube
    String key = "AIzaSyBJffXixRGSguaXNQxbtZb_am90NI9nGHg";
    String channelId = "UCeLNPJoPAio9rT2GAdXDVmw";

    List<NotificationCloud> notifications = new List<NotificationCloud>();

    //bool streamingReachable = false;
    FilePickerGlobal filePickerGlobal;

    String error_email_already_in_use = "ERROR_EMAIL_ALREADY_IN_USE";
    String error_unknown = "ERROR_UNKNOWN";

    String register_error_title = "Error en el registro";
    String signin_error_title = "Error de autentificación";

    Future<CurupaUser> getUserData(String userId) async {
      if (userId != null) {
        CurupaUser _user = new CurupaUser();
        await Auth.getUserDocumentReference(userId)
            .then((userDocumentReference) async {
          await userDocumentReference.get().then((userSnapshot) async {
            if (userSnapshot.exists) {
              DocumentReference yearDocumentReference =
              userSnapshot.data()["yearRef"];
              if (yearDocumentReference != null) {
                await yearDocumentReference.get().then((yearSnapshot) async {
                  if (yearSnapshot.exists) {
                    _user.userRef = userDocumentReference;
                    try {
                      group = await Group.fromDocument(yearSnapshot);
                      userSnapshot.data()["group"] = group;
                      _user = await CurupaUser.fromDocument(userSnapshot);
                      return _user;
                    } on Exception catch (exception) {
                      print(exception.toString());
                    } catch (error) {
                      print(error.toString());
                    }
                  }
                });
              } else {
                _user = await CurupaUser.fromDocument(userSnapshot);
                return _user;
              }
            }
          });
        });
        return _user;
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

    void initData() {
      AppData _dataPost = new AppData(
        name: 'Curupa',
        avatar: 'assets/images/escudo.png',
        home_background: 'assets/images/cancha.png',
        group_background: 'assets/images/group_backgrnd.png',
        location: 'Hurlingham, Buenos Aires',
      );
      appData = _dataPost;
      appData = _dataPost;
    }

    void setDataFromGlobal() {
      setData(
          description.description,
          posts,
          museums,
          newsletterContent.contents,
          pumasContent.contents,
          anecdoteContent.contents,
          valoresContent.contents
      );
    }

    void setData(
        String desc,
        List<Post> posts,
        List<Museum> museums,
        List<HTML> newsletters,
        List<HTML> pumas,
        List<HTML> anecdotes,
        List<HTML> valores) {

      appData.biography = desc;
      appData.posts = posts;
      appData.museums = museums;
      appData.newsletters = newsletters;
      appData.anecdotes = anecdotes;
      appData.pumas = pumas;
      appData.valores = valores;
    }

    void showErrorAlert(
        { BuildContext context,
          String title,
          String content,
          VoidCallback onPressed } ) {

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

        String _path;

        _pickingType = fileType; //FileType.IMAGE;
        _hasValidMime = true;
        _paths = null;

        FilePickerResult result = await FilePicker.platform.pickFiles(
          type: _pickingType,
          allowedExtensions: ['jpg', 'png', 'doc'],
        );

        //_path = await FilePicker.getFilePath(
            //type: _pickingType); //, fileExtension: _extension);

        /*if (upload) {
              await uploadFile(_path).then((url) async {
                return url;
              });
            } else {
              return _path;
            }*/

        if(result != null) {
          PlatformFile file = result.files.first;

          _path = file.path;

          /*print(file.name);
          print(file.bytes);
          print(file.size);
          print(file.extension);
          print(file.path);*/

        } else {
          // User canceled the picker
        }

        return _path;
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
        Reference storageRef =
        FirebaseStorage.instance.ref().child(childReference);
        String url = await storageRef.getDownloadURL();

        return url;
      }
    }

    class AppData {
      AppData({
        this.name,
        this.avatar,
        this.home_background,
        this.group_background,
        this.location,
        this.biography,
        this.posts,
        this.museums,
        this.pumas,
        this.drawers,
        this.newsletters,
        this.anecdotes,
        this.valores
      });

      final String name;
      final String avatar;
      final String home_background;
      final String group_background;
      final String location;
      String biography;
      List<Post> posts;
      List<Museum> museums;
      List<HTML> pumas;
      List<HTML> valores;
      final List<HTML> drawers;
      List<HTML> newsletters;
      List<HTML> anecdotes;
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
        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendSMS');
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

    void getDrawers() {
      Auth.getHtmlContentByType("drawer").then((HTMLS _drawer) {
        drawerContent = _drawer;
        drawerContent.contents.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        eventBus.fire("main-drawer");
      });
    }

    //HOME

    void getMuseums() async {
      Auth.getMuseumSnapshots().then((templist) {
        Auth.getMuseum(templist).then((List<Museum> _museums) {
          museums = _museums;
          eventBus.fire("home-museum");
        });
      });
    }

    void getPumas() {
      Auth.getHtmlContentByType("pumas").then((HTMLS _pumasContent) {
        pumasContent = _pumasContent;
        pumasContent.contents.sort((a, b) {
          return a.last_update.compareTo(b.last_update);
        });
        eventBus.fire("home-pumas");
      });
    }

    void getValores() {
      Auth.getHtmlContentByType("valores").then((HTMLS _valoresContent) {
        valoresContent = _valoresContent;
        valoresContent.contents.sort((a, b) {
          return a.last_update.compareTo(b.last_update);
        });
        eventBus.fire("home-valores");
      });
    }

    void getDescription() {
      Stream<Description> descStream = Auth.getDescription();
      descStream.listen((Description _desc) {
        description = _desc;
        eventBus.fire("home-description");
        return _desc;
      });
    }

    void getPosts() {
      Auth.getPostSnapshots().then((templist) {
        Auth.getPost(templist).then((List<Post> _posts) {
          posts = _posts;
          eventBus.fire("home-posts");
        });
      });
    }

    void getNewsletters() {
      Auth.getHtmlContentByType("newsletter").then((HTMLS _newsletterContent) {
        newsletterContent = _newsletterContent;
        newsletterContent.contents.sort((a, b) {
          return a.last_update.compareTo(b.last_update);
        });
        eventBus.fire("home-newsletter");
      });
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
      String groupId = group.documentID;
      Auth.getGroupVideoMediaByType(groupId)
          .then((List<GroupMedia> listGroupMedia) {
        group.medias = listGroupMedia;
        eventBus.fire("group-media");
      });
    }

    void getAnecdotes() async {
      Auth.getHtmlContentByTypeAndGroup("anecdote", group.yearRef)
          .then((HTMLS _anecdote) {
        anecdoteContent = _anecdote;
        anecdoteContent.contents.sort((a, b) {
          return a.last_update.compareTo(b.last_update);
        });
        eventBus.fire("group-anecdotes");
      });
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
          fontSize: 16.0
      );
    }
