
    import 'dart:async';
    import 'dart:io';
    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:cloud_functions/cloud_functions.dart';
    import 'package:device_info/device_info.dart';
    import 'package:event_bus/event_bus.dart';
    import 'package:file_picker/file_picker.dart';
    import 'package:firebase_storage/firebase_storage.dart';
    import 'package:flutter/cupertino.dart';
    import 'package:flutter/material.dart';
    import 'package:curupas/models/description.dart';
    import 'package:curupas/models/post.dart';
    import 'package:curupas/models/group.dart';
    import 'package:curupas/models/user.dart';
    import 'package:curupas/ui/screens/widgets/alert_dialog.dart';
    import 'package:video_thumbnail/video_thumbnail.dart';
    import 'package:youtube_api/youtube_api.dart';
    import 'business/auth.dart';
    import 'models/HTML.dart';
    import 'models/HTMLS.dart';
    import 'models/museum.dart';
    import 'models/streaming.dart';
    import 'package:path/path.dart' as p;
    import 'dart:math' as math;


    User user = new User();
    Group group = new Group();

    EventBus eventBus = EventBus();

    //App Data object
    AppData appData = new AppData();

    //APP CONTENT FOR Data
    Description description = new Description();
    List<Post> posts = new List<Post>();
    List<Museum> museums = new List<Museum>();

    //HTML CONTENT
    HTMLS drawerContent = new HTMLS();
    HTMLS newsletterContent = new HTMLS();
    HTMLS anecdoteContent = new HTMLS();

    //_globals.setData(desc, posts, museums, newsletters, _globals.anecdoteContent.contents);

    Streammer streammer;
    bool streamingReachable = false;
    FilePickerGlobal filePickerGlobal;

    String error_email_already_in_use = "ERROR_EMAIL_ALREADY_IN_USE";
    String error_unknown = "ERROR_UNKNOWN";

    String register_error_title = "Error en el registro";
    String signin_error_title = "Error de autentificación";

    Future<User> getUserData(String userId) async {
      if (userId != null) {
        User _user = new User();
        await Auth.getUserDocumentReference(userId)
            .then((userDocumentReference) async {
          await userDocumentReference.get().then((userSnapshot) async {
            if (userSnapshot.exists) {
              DocumentReference yearDocumentReference =
                  userSnapshot.data["yearRef"];
              if (yearDocumentReference != null) {
                await yearDocumentReference.get().then((yearSnapshot) async {
                  if (yearSnapshot.exists) {
                    _user.userRef = userDocumentReference;
                    try {
                      group = await Group.fromDocument(yearSnapshot);
                      userSnapshot.data["group"] = group;
                      _user = await User.fromDocument(userSnapshot);
                      Auth.getGroupVideoMediaByType(group.documentID);
                      return _user;
                    } on Exception catch (exception) {
                      print(exception.toString());
                    } catch (error) {
                      print(error.toString());
                    }
                  }
                });
              } else {
                _user = await User.fromDocument(userSnapshot);
                return _user;
              }
            }
          });
        });
        return _user;
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

    void initData(){
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
      setData(description.description, posts, museums, newsletterContent.contents, anecdoteContent.contents);
    }

    void setData(String desc,
        List<Post> posts,
        List<Museum> museums,
        List<HTML> newsletters,
        List<HTML> anecdotes) {

      appData.biography = desc;
      appData.posts = posts;
      appData.museums = museums;
      appData.newsletters = newsletters;
      appData.anecdotes = anecdotes;
    }

    void queryDevice() async {

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');

      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}');  // e.g. "Moto G (4)"

      // e.g. "iPod7,1"


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
        String _path;
        _pickingType = fileType; //FileType.IMAGE;
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

      Future<Image> getThumbnailFromVideo(String path) async {
        final uint8list = await VideoThumbnail.thumbnailData(
          video: path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 300, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 25,
        );
        return new Image.memory(uint8list);
      }

      Future<bool> uploadFile(
          String _imagePath,
          String filePath,
          StorageMetadata metadata
          ) async {

        String extension = p.extension(_imagePath);
        //String fileFolderExtension = folder + "/" +  fileName + '$extension';

        String fileFolderExtension = filePath + '$extension';

        StorageReference storageRef =
            FirebaseStorage.instance.ref().child(fileFolderExtension);

        StorageUploadTask uploadTask =
            storageRef.putFile(File(_imagePath), metadata);

        //int count = 0;

        //StreamSubscription<StorageTaskEvent> streamSubscription =
        //uploadTask.events.listen((event) {
          //if ( count == 0 ) {
          //  return event.toString();
          //} else {
            //double _progess = event.snapshot.bytesTransferred.toDouble() / event.snapshot.totalByteCount.toDouble();
            //return _progess.toString();
          //}
          //count++;
        //});

        //StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

       await uploadTask.onComplete.then((completed)  {

          //String url = (await downloadUrl.ref.getDownloadURL());
          //streamSubscription.cancel();
          return true;

        });



      }

      Future<String> getStorageFileUrl(String childReference) async {
        StorageReference storageRef =
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
        this.drawers,
        this.newsletters,
        this.anecdotes,
      });

      final String name;
      final String avatar;
      final String home_background;
      final String group_background;
      final String location;
      String biography;
      List<Post> posts;
      List<Museum> museums;
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
