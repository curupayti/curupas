import 'dart:async';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onboarding_flow/models/description.dart';
import 'package:onboarding_flow/models/feeds.dart';
import 'package:onboarding_flow/models/group.dart';
import 'package:onboarding_flow/models/user.dart';
import 'package:flutter/services.dart';
import 'package:onboarding_flow/globals.dart' as _globals;
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
    /*try {
      authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    } on Exception catch (exception) {
      print(exception.toString());
    }
    String uid = authResult.user.uid;
    setUserFrefs(uid);
    return uid;*/
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
    Firestore.instance.document("users/${userId}").setData(data);
    await _globals.getUserData(userId).then((user) {
      return user;
    });
    return null;
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

  static Stream<User> getUser(String userID, String year, String name) {
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

  static Future<List<Post>> getPosts() async {
    List<DocumentSnapshot> templist;
    List<Post> list = new List();
    CollectionReference collectionRef = Firestore.instance.collection("posts");
    QuerySnapshot collectionSnapshot = await collectionRef.getDocuments();
    templist = collectionSnapshot.documents;

    list = await templist.map((DocumentSnapshot docSnapshot) {
      getPostImages(docSnapshot.documentID).then((imagesList) {
        return Post.fromDocument(docSnapshot, imagesList);
      });
    }).toList();

    return list;
  }

  static Future<List<String>> getPostImages(String documentId) async {
    List<DocumentSnapshot> templist;
    List<String> imageList = new List();
    CollectionReference collectionRef = Firestore.instance
        .collection('posts')
        .document(documentId)
        .collection('images');
    QuerySnapshot collectionSnapshot = await collectionRef.getDocuments();

    templist = collectionSnapshot.documents; // <--- ERROR

    imageList = templist.map((DocumentSnapshot docSnapshot) {
      Map<String, Object> doc = docSnapshot.data;
      String url = doc["downloadURL"];
      imageList.add(url);
    }).toList();

    return imageList;
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
