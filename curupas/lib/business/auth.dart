import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:curupas/models/HTML.dart';
import 'package:curupas/models/HTMLS.dart';
import 'package:curupas/models/curupa_user.dart';
import 'package:curupas/models/description.dart';
import 'package:curupas/models/group.dart';
import 'package:curupas/models/group_media.dart';
import 'package:curupas/models/museum.dart';
import 'package:curupas/models/notification.dart';
import 'package:curupas/models/post.dart';
import 'package:curupas/models/sms.dart';
import 'package:curupas/models/streaming.dart';
import 'package:curupas/models/streaming_thumbnails.dart';
import 'package:curupas/models/streaming_video.dart';
import 'package:curupas/models/update.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cache.dart';

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
    final AuthCredential credential =
        FacebookAuthProvider.credential(accessToken);
    final User user = (await _auth.signInWithCredential(credential)).user;
    setUserFrefs(user.uid);
    return user.uid;
  }

  static Future<String> signInGuest() async {
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
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .delete();
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
          .doc("${userId}")
          .set(data, options);
    } catch (e) {
      print(e);
    }
    return await _globals.getUserData(userId);
  }

  //TODO listen update and load accordingly
  static updateListener(String documentId) {
    CollectionReference reference =
        FirebaseFirestore.instance.collection("updates");
    reference.snapshots().listen((querySnapshot) {
      querySnapshot.docChanges.forEach((change) {
        switch (change.newIndex.toString()) {
          case "calendar":
            break;
          case "group":
            break;
          case "home":
            break;
          case "profile":
            break;
        }
      });
    });
  }

  static void updateUserSmsChecked(String userID, bool checked) async {
    await FirebaseFirestore.instance
        .doc("users/${userID}")
        .set({'smsChecked': checked}, SetOptions(merge: true));
  }

  static Future<DocumentReference> getRoleGroupReferenceByPath(
      String path) async {
    DocumentReference roleRef = await FirebaseFirestore.instance.doc(path);
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
    DocumentReference yearRef = await FirebaseFirestore.instance
        .collection('years')
        .add({'year': year});
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

  static Future<Group> getGroupByYear(String year) async {
    CollectionReference collectionRef = await FirebaseFirestore.instance
        .collection("years")
        .where("year", isEqualTo: year);
    QuerySnapshot snapshot = await Cache.getCacheCollection(collectionRef);
    return await snapshot.docs.map((doc) {
      return Group.fromDocument(doc);
    }).first;
  }

  static setMediaListener(String documentId) {
    CollectionReference reference =
        FirebaseFirestore.instance.collection("years/${documentId}/media");
    reference.snapshots().listen((querySnapshot) {
      querySnapshot.docChanges.forEach((change) {
        DocumentChange doc = change;
        if (change.type == DocumentChangeType.added) {
          print("document: ${change.doc.data()} added");
          GroupMedia groupMedia = GroupMedia.fromDocument(change.doc);
          bool contains = containsGroupMedia(groupMedia.documentID);
          print(contains);
          //Esto es inconsistente si dos medias tienen el mismo titulo.
          if (contains == false) {
            Cache.appData.group.medias.add(groupMedia);
            _globals.eventBus.fire("added");
          }
        }
      });
    });
  }

  static bool containsGroupMedia(String groupMediaID) {
    int length = Cache.appData.group.medias.length;
    for (var i = 0; i < length; i++) {
      String _groupMediaID = Cache.appData.group.medias[i].documentID;
      if (_groupMediaID == groupMediaID) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> getUpdates() async {
    final completer = Completer<bool>();
    List<DocumentSnapshot> templist = [];
    List<Update> listUpdates = [];
    CollectionReference updateCollection =
        await FirebaseFirestore.instance.collection("updates");
    updateCollection.snapshots().listen((collectionSnapshot) async {
      templist = collectionSnapshot.docs;
      listUpdates = await templist.map((DocumentSnapshot docSnapshot) {
        return Update.fromDocument(docSnapshot);
      }).toList();
      await Cache.updated(listUpdates);
      completer.complete();
    });
    return completer.future;
  }

  static Future<List<GroupMedia>> getMedias(DocumentSnapshot document) async {
    CollectionReference collectionReference =
        await document.reference.collection("media");
    QuerySnapshot collectionSnapshot =
        await Cache.getCacheCollection(collectionReference);
    List<DocumentSnapshot> templist;
    List<GroupMedia> listGroupMedia = [];
    templist = collectionSnapshot.docs;
    listGroupMedia = await templist.map((DocumentSnapshot docSnapshot) {
      return GroupMedia.fromDocument(docSnapshot);
    }).toList();
    return listGroupMedia;
  }

  static Future<CurupaUser> getUser(String userID) async {
    CurupaUser user;
    DocumentSnapshot document = await Cache.getCacheDocument("users/${userID}");
    if (document.exists) {
      user = CurupaUser.fromDocument(document);
    }
    return user;
  }

  static Future<SMS> getUserDataForSMS(String userID) async {
    DocumentSnapshot doc = await Cache.getCacheDocument("users/${userID}");
    if (doc.exists) {
      SMS sms = new SMS();
      sms.smsCode = doc.data()["smsCode"];
      sms.smsId = doc.data()["smsId"];
      sms.smsChecked = doc.data()["smsChecked"];
      sms.phone = doc.data()["phone"];
      sms.userId = doc.id;
      return sms;
    }
  }

  static void updateUserPhone(String phone) async {
    String userID = Cache.appData.user.userID;
    await FirebaseFirestore.instance
        .doc("users/${userID}")
        .set({'phone': phone}, SetOptions(merge: true));
  }

  static Future<Description> getDescription() async {
    DocumentSnapshot docSnap = await Cache.getCacheDocument("titles/home");
    if (docSnap.exists) {
      return Description.fromDocument(docSnap);
    }
  }

  static Future<HTMLS> getHtmlContentByType(String type) async {
    HTMLS _drawerContent = HTMLS();
    DocumentSnapshot document =
        await Cache.getCacheDocument("contents/${type}");
    if (document.exists) {
      await getContenHtmls(document).then((listContentHtml) {
        _drawerContent = HTMLS.fromDocument(document, listContentHtml);
      });
    }
    return _drawerContent;
  }

  static Future<HTMLS> getHtmlContentByTypeAndGroup(
      String type, DocumentReference group_red) async {
    HTMLS _htmlContent = HTMLS();
    DocumentSnapshot document =
        await Cache.getCacheDocument("contents/${type}");
    //await FirebaseFirestore.instance.doc("contents/${type}").get();
    if (document.exists) {
      List<HTML> _content = await getContenHtmlsBygroup(document, group_red);
      _htmlContent = HTMLS.fromDocument(document, _content);
    }
    return _htmlContent;
  }

  static Future<List<HTML>> getContenHtmls(DocumentSnapshot document) async {
    CollectionReference collectionReference =
        await document.reference.collection("collection");
    QuerySnapshot collectionSnapshot =
        await Cache.getCacheCollection(collectionReference);
    List<DocumentSnapshot> templist;
    List<HTML> listContentHtml = [];
    templist = collectionSnapshot.docs;
    listContentHtml = await templist.map((DocumentSnapshot docSnapshot) {
      return HTML.fromDocument(docSnapshot);
    }).toList();
    return listContentHtml;
  }

  static Future<List<HTML>> getContenHtmlsBygroup(
      DocumentSnapshot document, DocumentReference group_red) async {
    List<DocumentSnapshot> templist;
    List<HTML> listContentHtml = [];
    CollectionReference collectionRef = await document.reference
        .collection("collection")
        .where("group_ref", arrayContains: group_red); //isEqualTo: group_red);
    QuerySnapshot collectionSnapshot =
        await Cache.getCacheCollection(collectionRef);
    templist = collectionSnapshot.docs;
    listContentHtml = await templist.map((DocumentSnapshot docSnapshot) {
      return HTML.fromDocument(docSnapshot);
    }).toList();
    return listContentHtml;
  }

  static Future<List<NotificationCloud>> getNotifications() async {
    List<NotificationCloud> notiList = [];
    QuerySnapshot collectionSnapshot =
        await Cache.getCacheCollectionGroup('notifications');
    for (var doc in collectionSnapshot.docs) {
      NotificationCloud noti = NotificationCloud.fromDocument(doc);
      notiList.add(noti);
    }
    print(notiList);
    return notiList;
  }

  static Future<NotificationCloud> getNotificationById(
      String notificationId) async {
    List<DocumentSnapshot> templist;
    CollectionReference collectionRef = await FirebaseFirestore.instance
        .collection("notifications/{$notificationId}");
    QuerySnapshot collectionSnapshot =
        await Cache.getCacheCollection(collectionRef);
    templist = collectionSnapshot.docs;
    await templist.map((DocumentSnapshot docSnapshot) {
      return NotificationCloud.fromDocument(docSnapshot);
    });
  }

  static Future<List<GroupMedia>> getGroupVideoMediaByType(
      String documentId) async {
    List<GroupMedia> list = [];
    DocumentSnapshot docSnap =
        await Cache.getCacheDocument("years/${documentId}");
    if (docSnap.exists) {
      await getMedias(docSnap).then((listGroupMedia) {
        setMediaListener(documentId);
        list = listGroupMedia;
      });
    }
    return list;
  }

  static Future<List<CurupaUser>> getFriends() async {
    List<DocumentSnapshot> templist;
    List<CurupaUser> list = [];
    DocumentReference yearRef = Cache.appData.user.yearRefs[0];
    CollectionReference collectionRef = await FirebaseFirestore.instance
        .collection("users")
        .where("yearRef", arrayContains: yearRef);
    QuerySnapshot collectionSnapshot =
        await Cache.getCacheCollection(collectionRef);
    templist = collectionSnapshot.docs;
    list = (await templist.map((DocumentSnapshot docSnapshot) {
      return CurupaUser.fromDocument(docSnapshot);
    }).toList())
        .cast<CurupaUser>();
    return list;
  }

  static Future<List<DocumentSnapshot>> getPostSnapshots() async {
    List<DocumentSnapshot> templist;
    List<Post> list = [];
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("posts");
    QuerySnapshot collectionSnapshot =
        await Cache.getCacheCollection(collectionRef);
    return collectionSnapshot.docs;
  }

  static Future<List<Post>> getPost(List<DocumentSnapshot> snapshots) async {
    var length = snapshots.length;
    List<Post> posts = [];
    List<DocumentSnapshot> templist;
    for (var snapshot in snapshots) {
      CollectionReference collectionRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(snapshot.id)
          .collection('images');
      QuerySnapshot collectionSnapshot =
          await Cache.getCacheCollection(collectionRef);
      templist = collectionSnapshot.docs; // <--- ERROR
      try {
        List<String> imageList = [];
        templist.map((DocumentSnapshot docSnapshot) {
          //Map<String, dynamic> doc = docSnapshot.data as Map<String, dynamic>;
          Map<String, dynamic> doc =
              new Map<String, dynamic>.from(docSnapshot.data());
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
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("museums");
    QuerySnapshot collectionSnapshot =
        await Cache.getCacheCollection(collectionRef);
    return collectionSnapshot.docs;
  }

  static Future<List<Museum>> getMuseum(
      List<DocumentSnapshot> snapshots) async {
    var length = snapshots.length;
    List<Museum> museums = [];
    List<DocumentSnapshot> templist;
    for (var snapshot in snapshots) {
      CollectionReference collectionRef = FirebaseFirestore.instance
          .collection('museums')
          .doc(snapshot.id)
          .collection('images');
      QuerySnapshot collectionSnapshot =
          await Cache.getCacheCollection(collectionRef);
      templist = collectionSnapshot.docs;
      var i = templist.length;
      try {
        List<String> imageList = [];
        templist.map((DocumentSnapshot docSnapshot) {
          Map<String, dynamic> doc =
              new Map<String, dynamic>.from(docSnapshot.data());
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
    QuerySnapshot userEvents = await Cache.getCacheCollectionByPath(
        'calendar/$name/${name}_collection');
    return userEvents;
  }

  static Future<QuerySnapshot> getCalendarEvents(
      DateTime _eventDate, String name) async {
    CollectionReference collectionRef = await FirebaseFirestore.instance
        .collection('calendar/$name/${name}_collection')
        .where('start',
            isGreaterThan: new DateTime(_eventDate.year, _eventDate.month,
                _eventDate.day - 1, 23, 59, 59))
        .where('start',
            isLessThan: new DateTime(
                _eventDate.year, _eventDate.month, _eventDate.day + 1));
    QuerySnapshot eventsSnapshot =
        await Cache.getCacheCollection(collectionRef);
    debugPrint("${eventsSnapshot.docs.length}");
    return eventsSnapshot;
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
    List<Streaming> streaminlistg = [];
    try {
      if (Cache.appData.streammer.streamings.length == 0) {
        List<DocumentSnapshot> templist;
        CollectionReference collectionRef = FirebaseFirestore.instance
            .collection('streaming')
            .doc("control")
            .collection('videos');
        QuerySnapshot collectionSnapshot =
            await Cache.getCacheCollection(collectionRef);
        templist = collectionSnapshot.docs;
        int docsLength = templist.length;
        int docLengthMinusOne = docsLength - 1;
        int count = 0;
        List<String> imageList = [];
        await templist.map((DocumentSnapshot docSnapshot) async {
          Map<String, dynamic> doc =
              new Map<String, dynamic>.from(docSnapshot.data());
          var id = doc["uid"];
          //var channelId = doc["channelId"];
          //List<StreamingVideo> streamingvideos =
          //    await getStreamingVideosById(id);
          StreamingThumbnail pthumbnail = new StreamingThumbnail();
          pthumbnail.url = doc['thumbnail'];
          Streaming streaming = new Streaming(
            id: doc['id'],
            title: doc['title'],
            channelId: doc['channelId'],
            playListId: doc['uid'],
            description: doc['description'],
            //videos: streamingvideos,
            thumbnail: pthumbnail,
          );
          streaminlistg.add(streaming);
          print("count: ${count} docLengthMinusOne: ${docLengthMinusOne}");
          //if (count == docLengthMinusOne) {
          //  return streaminlistg;
          //}
          //count++;
        }).toList();
        print("streaminlistg: ${streaminlistg.length}");
      } else {
        streaminlistg = Cache.appData.streammer.streamings;
      }
    } on Exception catch (_) {
      print("Error: " + _.toString());
    }
    return streaminlistg;
  }

  static Future<List<StreamingVideo>> getStreamingVideosById(String id) async {
    List<StreamingVideo> streamingvideos = [];
    CollectionReference collectionRef = FirebaseFirestore.instance
        .collection('streaming')
        .doc("control")
        .collection('videos')
        .doc(id)
        .collection("videos");
    QuerySnapshot subCollectionSnapshot =
        await Cache.getCacheCollection(collectionRef);
    List<DocumentSnapshot> subTemplist = subCollectionSnapshot.docs;
    //var docsSubLength = subTemplist.length;
    //var countSub = 0;
    await subTemplist.map((DocumentSnapshot subDocSnapshot) async {
      Map<String, dynamic> subDoc =
          new Map<String, dynamic>.from(subDocSnapshot.data());
      var subId = subDoc["id"];
      StreamingVideo streamingvideo = new StreamingVideo();
      streamingvideo.id = subDoc["id"];
      streamingvideo.title = subDoc["title"];
      streamingvideo.description = subDoc["description"];
      streamingvideo.channelId = subDoc["channelId"];
      streamingvideo.position = subDoc["position"];
      streamingvideo.videoId = subDoc["videoId"];
      streamingvideo.publishedAt = subDoc["publishedAt"];
      streamingvideo.playlistId = subDoc["playlistId"];
      var thumbnail = subDoc["thumbnail"];
      if (thumbnail != "") {
        StreamingThumbnail st = new StreamingThumbnail();
        st.url = subDoc["thumbnail"];
        streamingvideo.thumbnail = st;
      }
      streamingvideos.add(streamingvideo);
    }).toList();
    return streamingvideos;
  }
}
