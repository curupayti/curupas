import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/models/HTMLS.dart';
import 'package:curupas/models/curupa_user.dart';
import 'package:curupas/models/description.dart';
import 'package:curupas/models/group.dart';
import 'package:curupas/models/museum.dart';
import 'package:curupas/models/notification.dart';
import 'package:curupas/models/post.dart';
import 'package:curupas/models/streammer.dart';
import 'package:curupas/models/update.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';

SharedPreferences prefs;

class AppData {
  AppData({
    this.name,
    this.avatar,
    this.home_background,
    this.group_background,
    this.location,
    this.biography,
    this.posts,
    this.description,
    this.drawerContent,
    this.newsletterContent,
    this.anecdoteContent,
    this.girasContent,
    this.pumasContent,
    this.valoresContent,
    this.user,
    this.curupaGuest,
    this.group,
    this.streammer,
    this.notifications,
  }) {
    this.name = 'Curupa';
    this.avatar = 'assets/images/escudo.png';
    this.home_background = 'assets/images/cancha.png';
    this.group_background = 'assets/images/group_backgrnd.png';
    this.location = 'Hurlingham, Buenos Aires';
    this.user = new CurupaUser();
    this.curupaGuest = new CurupaGuest();
    this.group = new Group();
    this.streammer = new Streammer();
  }
  String name;
  String avatar;
  String home_background;
  String group_background;
  String location;
  String biography;
  List<Post> posts;
  List<Museum> museums;
  Description description;
  HTMLS drawerContent;
  HTMLS newsletterContent;
  HTMLS anecdoteContent;
  HTMLS girasContent;
  HTMLS pumasContent;
  HTMLS valoresContent;
  HTMLS museumContent;
  CurupaUser user;
  CurupaGuest curupaGuest;
  Group group;
  Streammer streammer;
  List<NotificationCloud> notifications;
  List<CalendarCache> calendarCacheCurupas;
  UpdateCache updateCache;
  // calendarCacheCurupas;
  //CalendarCache calendarCachePartidos;
  //CalendarCache calendarCacheCamadas;
}

class CalendarCache {
  String name;
  int id;
  Future<QuerySnapshot> futureCalendarSnapshot;
  QuerySnapshot calendarSnapshot;
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

class Cache {
  //App Data object
  static AppData appData = new AppData();

  static Future<bool> checkCahed(String path) async {
    bool resutl = false;
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString(path) != null) {
      resutl = true;
    } else {
      resutl = false;
    }
    return resutl;
  }

  static Future<QuerySnapshot> getCacheCollectionByPath(
      String collection) async {
    CollectionReference collectionRef =
        await FirebaseFirestore.instance.collection(collection);
    return await getCacheCollection(collectionRef);
  }

  static Future<QuerySnapshot> getCacheCollection(
      CollectionReference collectionRef) async {
    QuerySnapshot collectionSnapshot =
        await collectionRef.get(GetOptions(source: Source.cache));
    if (collectionSnapshot.docs.length == 0) {
      collectionSnapshot =
          await collectionRef.get(GetOptions(source: Source.server));
    }
    return collectionSnapshot;
  }

  static Future<DocumentSnapshot> getCacheDocument(String path) async {
    DocumentSnapshot docuentSnapshot;
    DocumentReference document = await FirebaseFirestore.instance.doc(path);
    DocumentSnapshot docCache;
    try {
      docCache = await document.get(GetOptions(source: Source.cache));
      if (docCache.exists) {
        docuentSnapshot = docCache;
        return docuentSnapshot;
      }
      //else {
      //  docCache = await document.get(GetOptions(source: Source.server));
      //  docuentSnapshot = docCache;
      //}
    } catch (exception) {
      print("cae");
    }
    docCache = await document.get(GetOptions(source: Source.server));
    docuentSnapshot = docCache;
    return docuentSnapshot;
  }

  static Future<DocumentSnapshot> getCacheDocumentByReference(
      DocumentReference document) async {
    DocumentSnapshot docuentSnapshot;
    DocumentSnapshot docCache;
    try {
      docCache = await document.get(GetOptions(source: Source.cache));
      if (docCache.exists) {
        docuentSnapshot = docCache;
        return docuentSnapshot;
      }
      //else {
      //  docCache = await document.get(GetOptions(source: Source.server));
      //  docuentSnapshot = docCache;
      //}
    } catch (exception) {
      print("cae");
    }
    docCache = await document.get(GetOptions(source: Source.server));
    docuentSnapshot = docCache;
    return docuentSnapshot;
  }

  static Future<QuerySnapshot> getCacheCollectionGroup(String path) async {
    QuerySnapshot collectionSnapshot;
    collectionSnapshot = await FirebaseFirestore.instance
        .collectionGroup(path)
        .get(GetOptions(source: Source.cache));
    if (collectionSnapshot.docs.length > 0) {
      return collectionSnapshot;
    } else {
      return await FirebaseFirestore.instance
          .collectionGroup(path)
          .get(GetOptions(source: Source.server));
    }
  }
}
