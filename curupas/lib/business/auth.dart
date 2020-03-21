
  import 'dart:async';
  import 'package:curupas/models/HTML.dart';
  import 'package:curupas/models/HTMLS.dart';
  import 'package:curupas/models/group_media.dart';
  import 'package:curupas/models/museum.dart';
  import 'package:firebase_analytics/firebase_analytics.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:curupas/models/description.dart';
  import 'package:curupas/models/post.dart';
  import 'package:curupas/models/group.dart';
  import 'package:curupas/models/sms.dart';
  import 'package:curupas/models/user.dart';
  import 'package:flutter/services.dart';
  import 'package:curupas/globals.dart' as _globals;
  import 'package:shared_preferences/shared_preferences.dart';

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
      AuthResult authResult;
      String errorEsp;
      try {
        authResult = await _auth.signInWithEmailAndPassword(
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
      String uid = authResult.user.uid;
      return ResutlLogin(false, uid);
    }

    static Future<String> signInWithFacebok(String accessToken) async {
      final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: accessToken,
      );
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
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
      FirebaseUser user;
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

    static Future<void> signOut() async {
      return FirebaseAuth.instance.signOut();
    }

    static Future<FirebaseUser> getCurrentFirebaseUser() async {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      return user;
    }

    static Future<bool> addUser(User user) async {
      String userId = user.userID;
      bool checkUser = await checkUserExist(userId);
      if (!checkUser) {
        Firestore.instance.document("users/${userId}").setData(user.toJson());
        return true;
      } else {
        return false;
      }
    }

    static Future<User> updateUser(
        String userId, Map<String, dynamic> data) async {
      Firestore.instance
          .collection("users")
          .document("${userId}")
          .updateData(data);
      return await _globals.getUserData(userId);
    }

    static Future<DocumentReference> getRoleGroupReference() async {
      DocumentReference roleRef =
          await Firestore.instance.document("roles/group");
      return roleRef;
    }

    static Future<bool> checkUserExist(String userId) async {
      bool exists = false;
      try {
        await Firestore.instance.document("users/${userId}").get().then((doc) {
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
          await Firestore.instance.collection('years').add({'year': year});
      return yearRef;
    }

    static Future<bool> checkYearExist(String year) async {
      QuerySnapshot querySnapshot =
          await Firestore.instance.collection("years").getDocuments();
      for (var doc in querySnapshot.documents) {
        String docYear = doc['year'];
        if (year == docYear) {
          return true;
        }
      }
      return false;
    }

    static Stream<Group> getGroupByYear(String year) {
      return Firestore.instance
          .collection("years")
          .where("year", isEqualTo: year)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          return Group.fromDocument(doc);
        }).first;
      });
    }


    static getGroupVideoMediaByType(String documentId) async {
      Firestore.instance.document("years/${documentId}").get().then((DocumentSnapshot document) async {
        if (document.exists) {
          await getMedias(document).then((listGroupMedia) {
            _globals.group.medias = listGroupMedia;
          });
        }
      });
      setMediaListener(documentId);
    }

    static setMediaListener(String documentId) {
      CollectionReference reference = Firestore.instance.collection("years/${documentId}/media");
      reference.snapshots().listen((querySnapshot) {
        querySnapshot.documentChanges.forEach((change) {
          // Do something with change

            //print(change);

            DocumentChange doc = change;

            _globals.eventBus.fire("updated");
        });
      });
    }

    static Future<List<GroupMedia>> getMedias(DocumentSnapshot document) async {
      QuerySnapshot collectionSnapshot = await document.reference.collection("media").getDocuments();
      List<DocumentSnapshot> templist;
      List<GroupMedia> listGroupMedia = new List();
      templist = collectionSnapshot.documents;
      listGroupMedia = await templist.map((DocumentSnapshot docSnapshot) {
        return GroupMedia.fromDocument(docSnapshot);
      }).toList();
      return listGroupMedia;
    }

    static Stream<User> getUser(String userID) {
      return Firestore.instance
          .collection("users")
          .where("userID", isEqualTo: userID)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          print(doc.toString);
          return User.fromDocument(doc);
        }).first;
      });
    }

    static Future<SMS> getUserDataForSMS(String userID) async {
      DocumentReference document =
          await Firestore.instance.collection("users").document("${userID}");
      return await document.get().then((snapshot) async {
        if (snapshot.exists) {
          SMS sms = new SMS();
          sms.smsCode = snapshot.data["smsCode"];
          sms.smsId = snapshot.data["smsId"];
          sms.smsChecked = snapshot.data["smsChecked"];
          sms.phone = snapshot.data["phone"];
          sms.userId = snapshot.documentID;
          return sms;
        }
      });
    }

    static Future<DocumentReference> getUserDocumentReference(
        String userID) async {
      DocumentReference document =
          await Firestore.instance.collection('users').document(userID);
      return document;
    }

    static Stream<Description> getDescription() {
      return Firestore.instance
          .collection("titles")
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          return Description.fromDocument(doc);
        }).first;
      });
    }

    static Future<HTMLS> getHtmlContentByType(String type) async {
      HTMLS _drawerContent = HTMLS();
      await Firestore.instance.document("contents/${type}").get().then((document) async {
        if (document.exists) {
         await getContenHtmls(document).then((listContentHtml) {
           _drawerContent = HTMLS.fromDocument(document, listContentHtml);
          });
        }
      });
      return _drawerContent;
    }

    static Future<HTMLS> getHtmlContentByTypeAndGroup(String type, DocumentReference group_red) async {
      HTMLS _htmlContent = HTMLS();
      await Firestore.instance.document("contents/${type}").get().then((document) async {
        if (document.exists) {
          await getContenHtmlsBygroup(document, group_red).then((listContentHtml) {
            _htmlContent = HTMLS.fromDocument(document, listContentHtml);
          });
        }
      });
      return _htmlContent;
    }


    static Future<List<HTML>> getContenHtmls(DocumentSnapshot document) async {
      QuerySnapshot collectionSnapshot = await document.reference.collection("collection").getDocuments();
      List<DocumentSnapshot> templist;
      List<HTML> listContentHtml = new List();
      templist = collectionSnapshot.documents;
      listContentHtml = await templist.map((DocumentSnapshot docSnapshot) {
        return HTML.fromDocument(docSnapshot);
      }).toList();
      return listContentHtml;
    }

    static Future<List<HTML>> getContenHtmlsBygroup(DocumentSnapshot document, DocumentReference group_red) async {
      List<DocumentSnapshot> templist;
      List<HTML> listContentHtml = new List();
      QuerySnapshot collectionSnapshot = await document.reference.collection('collection').where("group_ref",isEqualTo: group_red).getDocuments();
      templist = collectionSnapshot.documents;
      listContentHtml = await templist.map((DocumentSnapshot docSnapshot) {
        return HTML.fromDocument(docSnapshot);
      }).toList();
      return listContentHtml;
    }


    static Future<List<User>> getUserById(String userId) async {
      List<DocumentSnapshot> templist;
      List<User> list = new List();
      DocumentReference yearRef = _globals.user.yearRef;
      QuerySnapshot collectionSnapshot =
          await Firestore.instance.collection("users").getDocuments();
      templist = collectionSnapshot.documents;
      list = await templist.map((DocumentSnapshot docSnapshot) {
        return User.fromDocument(docSnapshot);
      }).toList();
      return list;
    }

    static Future<List<User>> getFriends() async {
      List<DocumentSnapshot> templist;
      List<User> list = new List();
      DocumentReference yearRef = _globals.user.yearRef;
      QuerySnapshot collectionSnapshot = await Firestore.instance
          .collection("users")
          .where("yearRef", isEqualTo: yearRef)
          .getDocuments();
      templist = collectionSnapshot.documents;
      list = await templist.map((DocumentSnapshot docSnapshot) {
        return User.fromDocument(docSnapshot);
      }).toList();
      return list;
    }

    static Future<List<DocumentSnapshot>> getPostSnapshots() async {
      List<DocumentSnapshot> templist;
      List<Post> list = new List();
      CollectionReference collectionRef = Firestore.instance.collection("posts");
      QuerySnapshot collectionSnapshot = await collectionRef.getDocuments();
      return collectionSnapshot.documents;
    }

    static Future<List<Post>> getPost(List<DocumentSnapshot> snapshots) async {
      var length = snapshots.length;
      List<Post> posts = new List();
      List<DocumentSnapshot> templist;
      for (var snapshot in snapshots) {
        CollectionReference collectionRef = Firestore.instance
            .collection('posts')
            .document(snapshot.documentID)
            .collection('images');
        QuerySnapshot collectionSnapshot = await collectionRef.getDocuments();
        templist = collectionSnapshot.documents; // <--- ERROR
        try {
          List<String> imageList = new List();
          templist.map((DocumentSnapshot docSnapshot) {
            Map<String, Object> doc = docSnapshot.data;
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
      CollectionReference collectionRef = Firestore.instance.collection("museums");
      QuerySnapshot collectionSnapshot = await collectionRef.getDocuments();
      return collectionSnapshot.documents;
    }

    static Future<List<Museum>> getMuseum(List<DocumentSnapshot> snapshots) async {
      var length = snapshots.length;
      List<Museum> museums = new List();
      List<DocumentSnapshot> templist;
      for (var snapshot in snapshots) {
        CollectionReference collectionRef = Firestore.instance
            .collection('museums')
            .document(snapshot.documentID)
            .collection('images');
        QuerySnapshot collectionSnapshot = await collectionRef.getDocuments();
        templist = collectionSnapshot.documents; // <--- ERROR
        try {
          List<String> imageList = new List();
          templist.map((DocumentSnapshot docSnapshot) {
            Map<String, Object> doc = docSnapshot.data;
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

    static Future<QuerySnapshot> getCalendarData(DateTime _dateTime) async {
      QuerySnapshot userEvents = await Firestore.instance
          .collection('calendar')
          .where(
          'start', isGreaterThanOrEqualTo: new DateTime(_dateTime.year, _dateTime.month))
          .getDocuments();
      return userEvents;
    }

    static Future<QuerySnapshot> getCalendarEvents(DateTime _eventDate) async {
        QuerySnapshot events = await Firestore.instance
            .collection('calendar')
            .where('time', isGreaterThan: new DateTime(_eventDate.year, _eventDate.month, _eventDate.day-1, 23, 59, 59))
            .where('time', isLessThan: new DateTime(_eventDate.year, _eventDate.month, _eventDate.day+1))
            .getDocuments();
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

  }
