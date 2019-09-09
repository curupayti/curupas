import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onboarding_flow/models/description.dart';
import 'package:onboarding_flow/models/feeds.dart';
import 'package:onboarding_flow/models/user.dart';
import 'package:flutter/services.dart';
import 'package:onboarding_flow/globals.dart' as _globals;
import 'package:shared_preferences/shared_preferences.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

final FirebaseAuth _auth = FirebaseAuth.instance;
//final googleSignIn = new GoogleSignIn();

SharedPreferences prefs;

final analytics = new FirebaseAnalytics();

class Auth {
  static Future<String> signIn(String email, String password) async {
    final AuthResult authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    String uid = authResult.user.uid;
    setUserFrefs(uid);
    return uid;
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
