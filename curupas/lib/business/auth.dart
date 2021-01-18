
  import 'dart:async';
  import 'dart:collection';
  import 'package:cloud_functions/cloud_functions.dart';
  import 'package:curupas/models/HTML.dart';
  import 'package:curupas/models/HTMLS.dart';
  import 'package:curupas/models/curupa_user.dart';
  import 'package:curupas/models/group_media.dart';
  import 'package:curupas/models/museum.dart';
  import 'package:curupas/models/notification.dart';
  import 'package:curupas/models/streaming.dart';
  import 'package:curupas/models/streaming_thumbnails.dart';
  import 'package:curupas/models/streaming_video.dart';
  import 'package:firebase_analytics/firebase_analytics.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:curupas/models/description.dart';
  import 'package:curupas/models/post.dart';
  import 'package:curupas/models/group.dart';
  import 'package:curupas/models/sms.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/services.dart';
  import 'package:curupas/globals.dart' as _globals;
  import 'package:shared_preferences/shared_preferences.dart';
  import 'dart:convert';

  enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  SharedPreferences prefs;

  final analytics = new FirebaseAnalytics();

  //enum authProblems { UserNotFound, PasswordNotValid, NetworkError }

  class ResutlLogin {
    bool error = false;
    String result;

    ResutlLogin(bool error, String result) {
      this.error = error;
      this.result = result;
    }
  }

  class Auth {
    static Future<ResutlLogin> signIn(String email, String password) async {
      UserCredential userCredential;
      String errorEsp;
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        authProblems errorType;
        //if (Platform.isAndroid) {
        switch (e.message) {
          case 'There is no user record corresponding to this identifier. The user may have been deleted.':
            errorType = authProblems.UserNotFound;
            break;
          case 'The password is invalid or the user does not have a password.':
            errorType = authProblems.PasswordNotValid;
            break;
          case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
            errorType = authProblems.NetworkError;
            break;
          // ...
          default:
            print('Case ${e.message} is not yet implemented');
        }
        //} else if (Platform.isIOS) {
        /*  switch (e.code) {
            case 'Error 17011':
              errorType = authProblems.UserNotFound;
              break;
            case 'Error 17009':
              errorType = authProblems.PasswordNotValid;
              break;
            case 'Error 17020':
              errorType = authProblems.NetworkError;
              break;
            // ...
            default:
              print('Case ${e.message} is not yet implemented');
          }
        }*/

        switch (errorType) {
          case authProblems.UserNotFound:
            errorEsp =
                "El ususario no existe o pudo haber sido borrado. Verifica el email e intenta nuevamente.";
            break;
          case authProblems.PasswordNotValid:
            errorEsp = "Contraseña incorrecta.";
            break;
          case authProblems.NetworkError:
            errorEsp =
                "Se ha producido un error de red (como tiempo de espera, conexión interrumpida o host inaccesible).";
            break;
          default:
            errorEsp = "Error desconocido, contacta al desarrollador.";
            break;
        }

        return new ResutlLogin(true, errorEsp);
      }
      String uid = userCredential.user.uid;
      return ResutlLogin(false, uid);
    }

    static Future<String> signInWithFacebok(String accessToken) async {
      final AuthCredential credential = FacebookAuthProvider.credential(accessToken);
      final User user =
          (await _auth.signInWithCredential(credential)).user;
      setUserFrefs(user.uid);
      return user.uid;
    }

    static Future<String> signInGuest () async {
      UserCredential userCredential = await _auth.signInAnonymously();
      User user = userCredential.user;
      setUserFrefs(user.uid);
      return user.uid;
    }

    static void setUserFrefs(String userId) async {
      prefs = await SharedPreferences.getInstance();
      prefs.setBool('registered', true);
      prefs.setBool('group', true);
      prefs.setString('userId', userId);
    }

    static Future<String> signUp(String email, String password) async {
      User user;
      try {
        user = (await _auth.createUserWithEmailAndPassword(
                email: email, password: password))
            .user;
      } on Exception catch (exception) {
        String _e = exception.toString();
        if (_e.contains(_globals.error_email_already_in_use)) {
          return _globals.error_email_already_in_use;
        } else {
          return _globals.error_unknown;
        }
      }
      return user.uid;
    }

    static Future<void> deleteGuestAccount() async {
      User user = await FirebaseAuth.instance.currentUser;
      return user.delete();
    }

    static Future<void> deleteUserById(String userId) async {
      return await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    }

    static Future<void> signOut() async {
      return FirebaseAuth.instance.signOut();
    }

    static Future<User> getCurrentFirebaseUser() async {
      User user = await _auth.currentUser;
      return user;
    }

    static Future<bool> addUser(CurupaUser user) async {
      String userId = user.userID;
      bool checkUser = await checkUserExist(userId);
      if (!checkUser) {
        FirebaseFirestore.instance.doc("users/${userId}").set(user.toJson());
        return true;
      } else {
        return false;
      }
    }

    static Future<CurupaUser> updateUser(
        String userId, Map<String, dynamic> data) async {
      try {
        SetOptions options = new SetOptions(merge: true);
        FirebaseFirestore.instance
            .collection("users")
            .doc("${userId}").set(data, options);
      } catch (e) {
        print(e);
      }
      return await _globals.getUserData(userId);
    }

    static Future<DocumentReference> getRoleGroupReferenceByPath(String path) async {
      DocumentReference roleRef =
          await FirebaseFirestore.instance.doc(path);
      return roleRef;
    }

    static Future<bool> checkUserExist(String userId) async {
      bool exists = false;
      try {
        await FirebaseFirestore.instance.doc("users/${userId}").get().then((doc) {
          if (doc.exists)
            exists = true;
          else
            exists = false;
        });
        return exists;
      } catch (e) {
        return false;
      }
    }

    static Future<DocumentReference> addYear(String year) async {
      DocumentReference yearRef =
          await FirebaseFirestore.instance.collection('years').add({'year': year});
      return yearRef;
    }

    static Future<bool> checkYearExist(String year) async {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("years").get();
      for (var doc in querySnapshot.docs) {
        String docYear = doc['year'];
        if (year == docYear) {
          return true;
        }
      }
      return false;
    }

    static Stream<Group> getGroupByYear(String year) {
      return FirebaseFirestore.instance
          .collection("years")
          .where("year", isEqualTo: year)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.docs.map((doc) {
          return Group.fromDocument(doc);
        }).first;
      });
    }


    static Future<QuerySnapshot> getGroupSnapshot() async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("years").get();
      return querySnapshot;
    }

    static Future<QuerySnapshot> getClubSnapshot() async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("clubs").get();
      return querySnapshot;
    }

    static setMediaListener(String documentId) {
      CollectionReference reference = FirebaseFirestore.instance.collection("years/${documentId}/media");
      reference.snapshots().listen((querySnapshot) {
        querySnapshot.docChanges.forEach((change) {
            DocumentChange doc = change;
            if (change.type == DocumentChangeType.added){
              print("document: ${change.doc.data()} added");
              GroupMedia groupMedia = GroupMedia.fromDocument(change.doc);
              bool contains = containsGroupMedia(groupMedia.documentID);
              print(contains);
              //Esto es inconsistente si dos medias tienen el mismo titulo.
              if (contains==false) {
                _globals.group.medias.add(groupMedia);
                _globals.eventBus.fire("added");
              }
            }
        });
      });
    }

    static bool containsGroupMedia(String groupMediaID) {
      int length = _globals.group.medias.length;
      for (var i = 0; i< length; i++) {
        String _groupMediaID = _globals.group.medias[i].documentID;
        if (_groupMediaID == groupMediaID) {
          return true;
        }
      }
      return false;
    }

    static Future<List<GroupMedia>> getMedias(DocumentSnapshot document) async {
      QuerySnapshot collectionSnapshot = await document.reference.collection("media").get();
      List<DocumentSnapshot> templist;
      List<GroupMedia> listGroupMedia = new List();
      templist = collectionSnapshot.docs;
      listGroupMedia = await templist.map((DocumentSnapshot docSnapshot) {
        return GroupMedia.fromDocument(docSnapshot);
      }).toList();
      return listGroupMedia;
    }

    static Stream<CurupaUser> getUser(String userID) {
      return FirebaseFirestore.instance
          .collection("users")
          .where("userID", isEqualTo: userID)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.docs.map((doc) {
          print(doc.toString);
          return CurupaUser.fromDocument(doc);
        }).first;
      });
    }

    static Future<SMS> getUserDataForSMS(String userID) async {
      return await FirebaseFirestore.instance.doc("users/${userID}").get().then((doc) {
        if (doc.exists) {
          SMS sms = new SMS();
          sms.smsCode = doc.data()["smsCode"];
          sms.smsId = doc.data()["smsId"];
          sms.smsChecked = doc.data()["smsChecked"];
          sms.phone = doc.data()["phone"];
          sms.userId = doc.id;
          return sms;
        }
      });
    }

    static void updateUserPhone(String phone) async {
      String userID = _globals.user.userID;
      await FirebaseFirestore.instance.doc("users/${userID}").set({'phone': phone}, SetOptions(merge:true));
    }

    static Future<DocumentReference> getUserDocumentReference(
        String userID) async {
      DocumentReference document =
          await FirebaseFirestore.instance.collection('users').doc(userID);
      return document;
    }

    static Stream<Description> getDescription() {
      return FirebaseFirestore.instance
          .collection("titles")
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.docs.map((doc) {
          return Description.fromDocument(doc);
        }).first;
      });
    }

    static Future<HTMLS> getHtmlContentByType(String type) async {
      HTMLS _drawerContent = HTMLS();
      String carajo_la_puta_madre = type;
      await FirebaseFirestore.instance.doc("contents/${type}").get().then((document) async {
        if (document.exists) {
          await getContenHtmls(document).then((listContentHtml) {
            //Map<String, dynamic> map = {"doc":document,"list":listContentHtml};
            //_drawerContent = HTMLS.fromDocument(document, listContentHtml);
            _drawerContent = HTMLS.fromDocument(document, listContentHtml);
          });
        }
      });
      return _drawerContent;
    }

    static Future<HTMLS> getHtmlContentByTypeAndGroup(String type, DocumentReference group_red) async {
      HTMLS _htmlContent = HTMLS();
      await FirebaseFirestore.instance.doc("contents/${type}").get().then((document) async {
        if (document.exists) {
          await getContenHtmlsBygroup(document, group_red).then((listContentHtml) {
            _htmlContent = HTMLS.fromDocument(document, listContentHtml);
          });
        }
      });
      return _htmlContent;
    }

    static Future<List<HTML>> getContenHtmls(DocumentSnapshot document) async {
      QuerySnapshot collectionSnapshot = await document.reference.collection("collection").get();
      List<DocumentSnapshot> templist;
      List<HTML> listContentHtml = new List();
      templist = collectionSnapshot.docs;
      listContentHtml = await templist.map((DocumentSnapshot docSnapshot) {
        return HTML.fromDocument(docSnapshot);
      }).toList();
      return listContentHtml;
    }

    static Future<List<HTML>> getContenHtmlsBygroup(DocumentSnapshot document, DocumentReference group_red) async {
      List<DocumentSnapshot> templist;
      List<HTML> listContentHtml = new List();
      QuerySnapshot collectionSnapshot = await document.reference.collection('collection').where("group_ref",isEqualTo: group_red).get();
      templist = collectionSnapshot.docs;
      listContentHtml = await templist.map((DocumentSnapshot docSnapshot) {
        return HTML.fromDocument(docSnapshot);
      }).toList();
      return listContentHtml;
    }

    static Future<List<NotificationCloud>> getNotifications() async {
      List<NotificationCloud> notiList = new List();
      QuerySnapshot collectionSnapshot = await FirebaseFirestore.instance.collectionGroup('notifications').get();
      for (var doc in collectionSnapshot.docs)  {
        //print(doc.data);
        //DocumentReference notiRef = doc.reference.parent().reference().parent();
//        await notiRef.get().then((notiSnapshot) async {
//          NotificationCloud  noti = NotificationCloud.fromDocument(notiSnapshot);
//          notiList.add(noti);
//        });
        NotificationCloud  noti = NotificationCloud.fromDocument(doc);
        notiList.add(noti);
      }
      print(notiList);
      return notiList;
    }

    static Future<NotificationCloud> getNotificationById(String notificationId) async {
      List<DocumentSnapshot> templist;
      QuerySnapshot collectionSnapshot =
      await FirebaseFirestore.instance.collection("notifications/{$notificationId}").get();
      templist = collectionSnapshot.docs;
      await templist.map((DocumentSnapshot docSnapshot) {
        return NotificationCloud.fromDocument(docSnapshot);
      });
    }


    static Future<List<CurupaUser>> getUserById(String userId) async {
      List<DocumentSnapshot> templist;
      List<CurupaUser> list = new List();
      //DocumentReference yearRef = _globals.user.yearRef;
      QuerySnapshot collectionSnapshot =
          await FirebaseFirestore.instance.collection("users").get();
      templist = collectionSnapshot.docs;
      list = (await templist.map((DocumentSnapshot docSnapshot) {
        return CurupaUser.fromDocument(docSnapshot);
      }).toList()).cast<CurupaUser>();
      return list;
    }

    static Future<List<GroupMedia>> getGroupVideoMediaByType(String documentId) async {
      List<GroupMedia> list = new List();
      await FirebaseFirestore.instance.doc("years/${documentId}").get().then((DocumentSnapshot document) async {
        if (document.exists) {
          await getMedias(document).then((listGroupMedia) {
            setMediaListener(documentId);
            list = listGroupMedia;
          });
        }
      });
      return list;
    }


    static Future<List<CurupaUser>> getFriends() async {
      List<DocumentSnapshot> templist;
      List<CurupaUser> list = new List();
      DocumentReference yearRef = _globals.user.yearRef;
      QuerySnapshot collectionSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("yearRef", isEqualTo: yearRef)
          .get();
      templist = collectionSnapshot.docs;
      list = (await templist.map((DocumentSnapshot docSnapshot) {
        return CurupaUser.fromDocument(docSnapshot);
      }).toList()).cast<CurupaUser>();
      return list;
    }

    static Future<List<DocumentSnapshot>> getPostSnapshots() async {
      List<DocumentSnapshot> templist;
      List<Post> list = new List();
      CollectionReference collectionRef = FirebaseFirestore.instance.collection("posts");
      QuerySnapshot collectionSnapshot = await collectionRef.get();
      return collectionSnapshot.docs;
    }

    static Future<List<Post>> getPost(List<DocumentSnapshot> snapshots) async {
      var length = snapshots.length;
      List<Post> posts = new List();
      List<DocumentSnapshot> templist;
      for (var snapshot in snapshots) {
        CollectionReference collectionRef = FirebaseFirestore.instance
            .collection('posts')
            .doc(snapshot.id)
            .collection('images');
        QuerySnapshot collectionSnapshot = await collectionRef.get();
        templist = collectionSnapshot.docs; // <--- ERROR
        try {
          List<String> imageList = new List();
          templist.map((DocumentSnapshot docSnapshot) {
            //Map<String, dynamic> doc = docSnapshot.data as Map<String, dynamic>;
            Map<String, dynamic> doc = new Map<String, dynamic>.from(docSnapshot.data());
            String url = doc["downloadURL"];
            imageList.add(url);
          }).toList();
          Post _post = Post.fromDocument(snapshot, imageList);
          posts.add(_post);
        } on Exception catch (_) {
          print("Error: " + _.toString());
        }
      }
      return posts;
    }

    /////////////////////////


    static Future<List<DocumentSnapshot>> getMuseumSnapshots() async {
      List<DocumentSnapshot> templist;
      List<Museum> list = new List();
      CollectionReference collectionRef = FirebaseFirestore.instance.collection("museums");
      QuerySnapshot collectionSnapshot = await collectionRef.get();
      return collectionSnapshot.docs;
    }

    static Future<List<Museum>> getMuseum(List<DocumentSnapshot> snapshots) async {
      var length = snapshots.length;
      List<Museum> museums = new List();
      List<DocumentSnapshot> templist;
      for (var snapshot in snapshots) {
        CollectionReference collectionRef = FirebaseFirestore.instance
            .collection('museums')
            .doc(snapshot.id)
            .collection('images');
        QuerySnapshot collectionSnapshot = await collectionRef.get();
        templist = collectionSnapshot.docs;
        var i = templist.length;
        try {
          List<String> imageList = new List();
          templist.map((DocumentSnapshot docSnapshot) {
            Map<String, dynamic> doc = new Map<String, dynamic>.from(docSnapshot.data());
            String url = doc["downloadURL"];
            imageList.add(url);
          }).toList();
          Museum _museum = Museum.fromDocument(snapshot, imageList);
          museums.add(_museum);
        } on Exception catch (_) {
          print("Error: " + _.toString());
        }
      }
      return museums;
    }

    static Future<QuerySnapshot> getCalendarData(String name) async {
      QuerySnapshot userEvents = await FirebaseFirestore.instance
          .collection('calendar/$name/${name}_collection')
          .get();
      return userEvents;
    }

    static Future<QuerySnapshot> getCalendarEvents(DateTime _eventDate, String name) async {
        QuerySnapshot events = await FirebaseFirestore.instance
            .collection('calendar/$name/${name}_collection')
            .where('start', isGreaterThan: new DateTime(_eventDate.year, _eventDate.month, _eventDate.day-1, 23, 59, 59))
            .where('start', isLessThan: new DateTime(_eventDate.year, _eventDate.month, _eventDate.day+1))
            .get();
        debugPrint("${events.docs.length}");
        return events;
    }

    static String getExceptionText(Exception e) {
      if (e is PlatformException) {
        switch (e.message) {
          case 'There is no user record corresponding to this identifier. The user may have been deleted.':
            return 'User with this e-mail not found.';
            break;
          case 'The password is invalid or the user does not have a password.':
            return 'Invalid password.';
            break;
          case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
            return 'No internet connection.';
            break;
          case 'The email address is already in use by another account.':
            return 'Email address is already taken.';
            break;
          default:
            return 'Unknown error occured.';
        }
      } else {
        return 'Unknown error occured.';
      }
    }

    static Future<List<Streaming>> getStreaming() async {

      List<Streaming> streaminlistg = new List<Streaming>();

      try {

        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('streaming-media');

        final results = await callable();
        Map<dynamic, dynamic> channels = results.data;

        List<StreamingVideo> streamingvideos = new List<StreamingVideo>();

        for (var channel in channels.values) {

          var id = channel["channelId"];
          var videos = channel["videos"];

          for (var video in videos) {

            StreamingVideo streamingvideo = new StreamingVideo();
            streamingvideo.id             = video["id"];
            streamingvideo.title          = video["title"];
            streamingvideo.description    = video["description"];
            streamingvideo.channelId      = video["channelId"];
            streamingvideo.position       = video["position"];
            streamingvideo.videoId        = video["videoId"];
            streamingvideo.publishedAt    = video["publishedAt"];
            streamingvideo.playlistId     = video["playlistId"];
            var thumbnail                 = video["thumbnail"];
            if ( thumbnail != "" ) {
              StreamingThumbnail st = new StreamingThumbnail();
              st.url = video["thumbnail"];
              streamingvideo.thumbnail = st;
            }
            streamingvideos.add(streamingvideo);

          }

          StreamingThumbnail pthumbnail = new StreamingThumbnail();
          pthumbnail.url = channel['thumbnail'];

          Streaming streaming = new Streaming(
            id: channel['id'],
            title: channel['title'],
            channelId: channel['channelId'],
            playListId: channel['playListId'],
            description: channel['description'],
            videos: streamingvideos,
            thumbnail:pthumbnail,
          );

          streaminlistg.add(streaming);

        }

        return streaminlistg;

      } catch (e) {
        print('caught generic exception');
        print(e);
      }
    }

    static Future<List<Streaming>> getVideos(List<DocumentSnapshot> snapshots) async {

        var length = snapshots.length;

        List<Streaming> streamings = new List();

        try {

          for (var snapshot in snapshots) {
            Streaming streaming = new Streaming();

            StreamingThumbnail streamingThumbnails = new StreamingThumbnail();

            int thumbnail_height = snapshot['thumbnail_height'];
            int thumbnail_width = snapshot['thumbnail_width'];
            String thumbnail_url = snapshot['thumbnail_url'];

            streamingThumbnails.height = thumbnail_height;
            streamingThumbnails.width = thumbnail_width;
            streamingThumbnails.url = thumbnail_url;

            streaming.thumbnail = streamingThumbnails;

            String id = snapshot.id;

            List<DocumentSnapshot> templistVideos;
            CollectionReference collectionRefVideos = FirebaseFirestore.instance
                .collection('media')
                .doc(id)
                .collection('videos');

            QuerySnapshot collectionSnapshotVideos = await collectionRefVideos
                .get();
            List<StreamingVideo> videosList = new List();

            for (var doc in collectionSnapshotVideos.docs) {

              StreamingVideo streamingVideo = new StreamingVideo();
              streamingVideo.id = doc["id"];
              streamingVideo.title = doc["title"];
              streamingVideo.channelId = doc["channelId"];
              streamingVideo.channelTitle = doc["channelTitle"];
              streamingVideo.playlistId = doc["playlistId"];
              streamingVideo.position = doc["position"];
              streamingVideo.isLive = doc["isLive"];

              StreamingThumbnail streamingThumbnailsVideo = new StreamingThumbnail();

              int video_thumbnail_height = snapshot['thumbnail_height'];
              int video_thumbnail_width = snapshot['thumbnail_width'];
              String video_thumbnail_url = snapshot['thumbnail_url'];

              streamingThumbnailsVideo.width = video_thumbnail_height;
              streamingThumbnailsVideo.height = video_thumbnail_width;
              streamingThumbnailsVideo.url = video_thumbnail_url;

              streamingVideo.thumbnail = streamingThumbnailsVideo;
              videosList.add(streamingVideo);


            }

            Streaming _streaming = Streaming.fromDocument(
                snapshot, streamingThumbnails, videosList);
            streamings.add(_streaming);

          }

        } on Exception catch (_) {
          print("Error: " + _.toString());
        }

      return streamings;
    }

  }
