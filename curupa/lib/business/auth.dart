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
    final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;

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
    bool check = await checkUserExist(user.userID);
    if (!check) {
      print("user ${user.name} ${user.email} added");
      Firestore.instance
          .document("users/${user.userID}")
          .setData(user.toJson());
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> checkUserExist(String userID) async {
    bool exists = false;
    try {
      await Firestore.instance.document("users/$userID").get().then((doc) {
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

  static Future<DocumentReference> addGroup(String group) async {
    DocumentReference groupRef =
        await Firestore.instance.collection('groups').add({'year': group});
    return groupRef;
  }

  static Future<bool> checkGroupExist(String year) async {
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("groups").getDocuments();
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
        .collection("groups")
        .where("year", isEqualTo: year)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.documents.map((doc) {
        return Group.fromDocument(doc);
      }).first;
    });
  }

  static Stream<User> getUser(String userID) {
    return Firestore.instance
        .collection("users")
        .where("userID", isEqualTo: userID)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.documents.map((doc) {
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
        .collection("descriptions")
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.documents.map((doc) {
        return Description.fromDocument(doc);
      }).first;
    });
  }

  static Future<List<User>> getFriends() async {
    List<DocumentSnapshot> templist;
    List<User> list = new List();
    DocumentReference groupRef = _globals.user.groupRef;
    QuerySnapshot collectionSnapshot = await Firestore.instance
        .collection("users")
        .where("groupRef", isEqualTo: groupRef)
        .getDocuments();
    templist = collectionSnapshot.documents;
    list = await templist.map((DocumentSnapshot docSnapshot) {
      return User.fromDocument(docSnapshot);
    }).toList();
    return list;
  }

  static Future<List<Feed>> getFeed() async {
    List<DocumentSnapshot> templist;
    List<Feed> list = new List();
    CollectionReference collectionRef = Firestore.instance.collection("feeds");
    QuerySnapshot collectionSnapshot = await collectionRef.getDocuments();
    templist = collectionSnapshot.documents;

    list = await templist.map((DocumentSnapshot docSnapshot) {
      return Feed.fromDocument(docSnapshot); // docSnapshot.data;
    }).toList();

    return list;
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
