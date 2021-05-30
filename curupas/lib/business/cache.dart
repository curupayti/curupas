import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/globals.dart' as _globals;
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

  //UPDATES
  static Future<void> updated(List<Update> _updates) async {
    UpdateCache updateCache = new UpdateCache();
    for (var u in _updates) {
      switch (u.updateType.name) {
        case "main":
          updateCache.main = u.updateType;
          break;
        case "calendar":
          updateCache.calendar = u.updateType;
          break;
        case "group":
          updateCache.group = u.updateType;
          break;
        case "home":
          updateCache.home = u.updateType;
          break;
        case "profile":
          updateCache.profile = u.updateType;
          break;
      }
    }
    appData.updateCache = updateCache;
    checkUpdateByType(appData.updateCache.main);
    checkUpdateByType(appData.updateCache.home);
    checkUpdateByType(appData.updateCache.calendar);
    checkUpdateByType(appData.updateCache.group);
    checkUpdateByType(appData.updateCache.profile);
  }

  static Future<void> checkUpdateByType(UpdateType updateType) async {
    try {
      bool updated = false;
      for (var da in updateType.updates) {
        String id = da.id;
        var key = "${updateType.name}-${id}";
        int timecal = prefs.getInt(key);
        if (timecal != null) {
          if (timecal > 0) {
            DateTime dateCache = DateTime.fromMillisecondsSinceEpoch(
                (prefs.getInt(key) ?? DateTime.now().millisecondsSinceEpoch));
            DateTime dateUpdate = da.date.toDate();
            Duration timeDifference = dateUpdate.difference(dateCache);
            if (timeDifference.inMilliseconds > 0) {
              if (updateType.name == "main") {
                switch (id) {
                  case "user":
                    appData.user = null;
                    updated = true;
                    _globals.user_data_loaded = false;
                    break;
                  case "drawer":
                    appData.drawerContent = null;
                    updated = true;
                    _globals.drawer_data_loaded = false;
                    break;
                }
              }
              if (updateType.name == "home") {
                switch (id) {
                  case "description":
                    appData.description = null;
                    updated = true;
                    break;
                  case "museums":
                    appData.museumContent = null;
                    updated = true;
                    break;
                  case "newsletter":
                    appData.newsletterContent = null;
                    updated = true;
                    break;
                  case "posts":
                    appData.posts = null;
                    updated = true;
                    break;
                  case "posts":
                    appData.posts = null;
                    updated = true;
                    break;
                  case "pumas":
                    appData.pumasContent = null;
                    updated = true;
                    break;
                  case "valores":
                    appData.valoresContent = null;
                    updated = true;
                    break;
                }
                _globals.home_data_loaded = false;
              }
              if (updateType.name == "calendar") {
                switch (id) {
                  case "camada":
                    appData.calendarCacheCurupas[0] = null;
                    updated = true;
                    break;
                  case "curupa":
                    appData.calendarCacheCurupas[1] = null;
                    updated = true;
                    break;
                  case "partidos":
                    appData.calendarCacheCurupas[2] = null;
                    updated = true;
                    break;
                }
                _globals.calendar_data_loaded = false;
              }
              if (updateType.name == "group") {
                switch (id) {
                  case "anecdote":
                    appData.anecdoteContent = null;
                    updated = true;
                    break;
                  case "media":
                    appData.group.medias = null;
                    updated = true;
                    break;
                  case "giras":
                    appData.girasContent = null;
                    updated = true;
                    break;
                }
                _globals.group_data_loaded = false;
              }
              if (updateType.name == "profile") {
                switch (id) {
                  case "notification":
                    appData.user = null;
                    updated = true;
                    _globals.user_data_loaded = false;
                    break;
                }
              }
            }
          } else {
            setDate(key, da);
          }
        } else {
          setDate(key, da);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  static void setDate(String key, UpdateTime da) {
    int timeUpdate =
        DateTime.fromMicrosecondsSinceEpoch(da.date.microsecondsSinceEpoch)
            .millisecondsSinceEpoch;
    prefs.setInt(key, timeUpdate);
  }
}
