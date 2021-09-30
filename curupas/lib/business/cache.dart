import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:curupas/models/HTMLS.dart';
import 'package:curupas/models/category.dart';
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

String force_update_user = "force_update_user";
String force_update_drawer = "force_update_drawer";
String force_update_description = "force_update_description";
String force_update_museums = "force_update_museums";
String force_update_newsletter = "force_update_newsletter";
String force_update_posts = "force_update_posts";
String force_update_pumas = "force_update_pumas";
String force_update_valores = "force_update_valores";
String force_update_calendar_camada = "force_update_calendar_camada";
String force_update_calendar_curupa = "force_update_calendar_curupa";
String force_update_calendar_partidos = "force_update_calendar_partidos";
String force_update_calendar_categorias = "force_update_calendar_categorias";
String force_update_anecdote = "force_update_anecdote";
String force_update_media = "force_update_media";
String force_update_giras = "force_update_giras";
String force_update_notification = "force_update_notification";
String force_update_years = "force_update_years";
String force_update_categories = "force_update_categories";

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
  List<Group> years;
  List<Category> categories;
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

  /*static setPref() async {
    prefs = await SharedPreferences.getInstance();
  }*/

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
    QuerySnapshot collectionSnapshot;
    String collectionName = collectionRef.id;
    String collectionPath = collectionRef.path;
    bool force = false;
    if (collectionPath.contains("years")) {
      if (collectionPath.contains("/media")) {
        force = prefs.getBool(force_update_media);
        prefs.setBool(force_update_media, false);
      } else {
        force = prefs.getBool(force_update_years);
        prefs.setBool(force_update_years, false);
      }
    } else if (collectionPath.contains("categories")) {
      force = prefs.getBool(force_update_categories);
      prefs.setBool(force_update_categories, false);
    } else if (collectionPath.contains("calendar/camada/")) {
      force = prefs.getBool(force_update_calendar_camada);
      prefs.setBool(force_update_calendar_camada, false);
    } else if (collectionPath.contains("calendar/curupa/")) {
      force = prefs.getBool(force_update_calendar_curupa);
      prefs.setBool(force_update_calendar_curupa, false);
    } else if (collectionPath.contains("calendar/partidos/")) {
      force = prefs.getBool(force_update_calendar_partidos);
      prefs.setBool(force_update_calendar_partidos, false);
    } else if (collectionPath.contains("calendar/categorias/")) {
      force = prefs.getBool(force_update_calendar_categorias);
      prefs.setBool(force_update_calendar_categorias, false);
    }

    bool server = false;
    if (force == false) {
      collectionSnapshot =
          await collectionRef.get(GetOptions(source: Source.cache));
      if (collectionSnapshot.docs.length == 0) {
        server = true;
      } else {
        return collectionSnapshot;
      }
    } else {
      server = true;
    }

    if (server) {
      collectionSnapshot =
          await collectionRef.get(GetOptions(source: Source.server));
      return collectionSnapshot;
    }
  }

  static Future<DocumentSnapshot> getCacheDocument(String path) async {
    DocumentSnapshot docCache;
    DocumentSnapshot docuentSnapshot;
    DocumentReference document;
    try {
      document = await FirebaseFirestore.instance.doc(path);
      bool force = false;
      if (path.contains("users/")) {
        force = prefs.getBool(force_update_user);
        prefs.setBool(force_update_user, false);
      } else if (path.contains("contents/drawer/")) {
        force = prefs.getBool(force_update_drawer);
        prefs.setBool(force_update_drawer, false);
      } else if (path.contains("categories/")) {
        force = prefs.getBool(force_update_drawer);
        prefs.setBool(force_update_drawer, false);
      } else if (path.contains("titles/")) {
        force = prefs.getBool(force_update_description);
        prefs.setBool(force_update_description, false);
      } else if (path.contains("museums/")) {
        force = prefs.getBool(force_update_museums);
        prefs.setBool(force_update_museums, false);
      } else if (path.contains("contents/newsletter/")) {
        force = prefs.getBool(force_update_newsletter);
        prefs.setBool(force_update_newsletter, false);
      } else if (path.contains("posts/")) {
        force = prefs.getBool(force_update_posts);
        prefs.setBool(force_update_posts, false);
      } else if (path.contains("contents/pumas/")) {
        force = prefs.getBool(force_update_pumas);
        prefs.setBool(force_update_pumas, false);
      } else if (path.contains("contents/valores/")) {
        force = prefs.getBool(force_update_valores);
        prefs.setBool(force_update_valores, false);
      } else if (path.contains("contents/anecdote/")) {
        force = prefs.getBool(force_update_anecdote);
        prefs.setBool(force_update_anecdote, false);
      } else if (path.contains("contents/giras/")) {
        force = prefs.getBool(force_update_giras);
        prefs.setBool(force_update_giras, false);
      } else if (path.contains("notification/")) {
        force = prefs.getBool(force_update_notification);
        prefs.setBool(force_update_notification, false);
      }

      if (force == false) {
        docCache = await document.get(GetOptions(source: Source.cache));
        if (docCache.exists) {
          docuentSnapshot = docCache;
          return docuentSnapshot;
        }
      }
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
    prefs = await SharedPreferences.getInstance();
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
            Duration timeDifference;
            if (timecal == 0) {
              timeDifference = Duration(milliseconds: 1);
            } else {
              //DateTime dateCache = DateTime.fromMillisecondsSinceEpoch(
              //    (prefs.getInt(key) ?? DateTime.now().millisecondsSinceEpoch));
              DateTime dateCache = DateTime.fromMillisecondsSinceEpoch(timecal);
              DateTime dateUpdate = da.date.toDate();
              timeDifference = dateUpdate.difference(dateCache);
            }
            if (timeDifference.inMilliseconds > 0) {
              if (updateType.name == "main") {
                switch (id) {
                  case "user":
                    appData.user = null;
                    updated = true;
                    _globals.user_data_loaded = false;
                    prefs.setBool(force_update_user, true);
                    break;
                  case "drawer":
                    appData.drawerContent = null;
                    updated = true;
                    _globals.drawer_data_loaded = false;
                    prefs.setBool(force_update_drawer, true);
                    break;
                  case "categories":
                    appData.categories = null;
                    updated = true;
                    _globals.categories_data_loaded = false;
                    prefs.setBool(force_update_categories, true);
                    break;
                  case "years":
                    appData.years = null;
                    updated = true;
                    _globals.years_data_loaded = false;
                    prefs.setBool(force_update_years, true);
                    break;
                }
              }
              if (updateType.name == "home") {
                switch (id) {
                  case "description":
                    appData.description = null;
                    updated = true;
                    prefs.setBool(force_update_description, true);
                    break;
                  case "museums":
                    appData.museumContent = null;
                    updated = true;
                    prefs.setBool(force_update_museums, true);
                    break;
                  case "newsletter":
                    appData.newsletterContent = null;
                    updated = true;
                    prefs.setBool(force_update_newsletter, true);
                    break;
                  case "posts":
                    appData.posts = null;
                    updated = true;
                    prefs.setBool(force_update_posts, true);
                    break;
                  case "pumas":
                    appData.pumasContent = null;
                    updated = true;
                    prefs.setBool(force_update_pumas, true);
                    break;
                  case "valores":
                    appData.valoresContent = null;
                    updated = true;
                    prefs.setBool(force_update_valores, true);
                    break;
                }
                _globals.home_data_loaded = false;
              }
              if (updateType.name == "calendar") {
                switch (id) {
                  case "camada":
                    appData.calendarCacheCurupas[0] = null;
                    updated = true;
                    prefs.setBool(force_update_calendar_camada, true);
                    break;
                  case "curupa":
                    appData.calendarCacheCurupas[1] = null;
                    updated = true;
                    prefs.setBool(force_update_calendar_curupa, true);
                    break;
                  case "partidos":
                    appData.calendarCacheCurupas[2] = null;
                    updated = true;
                    prefs.setBool(force_update_calendar_partidos, true);
                    break;
                  case "categorias":
                    appData.calendarCacheCurupas[3] = null;
                    updated = true;
                    prefs.setBool(force_update_calendar_partidos, true);
                    break;
                }
                _globals.calendar_data_loaded = false;
              }
              if (updateType.name == "group") {
                switch (id) {
                  case "anecdote":
                    appData.anecdoteContent = null;
                    updated = true;
                    prefs.setBool(force_update_anecdote, true);
                    break;
                  case "media":
                    appData.group.medias = null;
                    updated = true;
                    prefs.setBool(force_update_media, true);
                    break;
                  case "giras":
                    appData.girasContent = null;
                    updated = true;
                    prefs.setBool(force_update_giras, true);
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
                    prefs.setBool(force_update_notification, true);
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

  static Category getCategoryFromId(String categoryId) {
    Category category;
    int length = appData.categories.length;
    for (int i = 0; i < length; i++) {
      if (categoryId == appData.categories[i].documentID) {
        category = appData.categories[i];
      }
    }
    return category;
  }
}
