import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveUpdate {
  String name;
  int id;
}

class UpdateTime {
  final String id;
  final Timestamp date;
  UpdateTime(this.id, this.date);
}

class UpdateType {
  final String name;
  final List<UpdateTime> updates;
  UpdateType(this.name, this.updates);
}

class UpdateCache {
  UpdateType main;
  UpdateType home;
  UpdateType calendar;
  UpdateType group;
  UpdateType profile;
  //SharedPreferences prefs;
  //UpdateCache(this.calendar, this.group, this.home, this.profile);
  /*Future<bool> checkCache() async {
    prefs = await SharedPreferences.getInstance();
    List<bool> resutls = [];
    resutls.add(check(main));
    resutls.add(check(home));
    resutls.add(check(calendar));
    resutls.add(check(group));
    resutls.add(check(profile));
    print("-------");
    print("UPDATE: ${resutls}");
    print("-------");
    if (resutls.contains(true)) {
      return true;
    } else {
      return false;
    }
  }*/

  /*bool check(UpdateType updateType) {
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
                    Cache.appData.user = null;
                    updated = true;
                    break;
                  case "drawer":
                    Cache.appData.drawerContent = null;
                    updated = true;
                    break;
                }
              }
              if (updateType.name == "home") {
                switch (id) {
                  case "description":
                    Cache.appData.description = null;
                    updated = true;
                    break;
                  case "museums":
                    Cache.appData.museumContent = null;
                    updated = true;
                    break;
                  case "newsletter":
                    Cache.appData.newsletterContent = null;
                    updated = true;
                    break;
                  case "posts":
                    Cache.appData.posts = null;
                    updated = true;
                    break;
                  case "posts":
                    Cache.appData.posts = null;
                    updated = true;
                    break;
                  case "pumas":
                    Cache.appData.pumasContent = null;
                    updated = true;
                    break;
                  case "valores":
                    Cache.appData.valoresContent = null;
                    updated = true;
                    break;
                }
              }
              if (updateType.name == "calendar") {
                switch (id) {
                  case "camada":
                    Cache.appData.calendarCacheCurupas[0] = null;
                    updated = true;
                    break;
                  case "curupa":
                    Cache.appData.calendarCacheCurupas[1] = null;
                    updated = true;
                    break;
                  case "partidos":
                    Cache.appData.calendarCacheCurupas[2] = null;
                    updated = true;
                    break;
                }
              }
              if (updateType.name == "group") {
                switch (id) {
                  case "anecdote":
                    Cache.appData.anecdoteContent = null;
                    updated = true;
                    break;
                  case "media":
                    Cache.appData.group.medias = null;
                    updated = true;
                    break;
                  case "giras":
                    Cache.appData.girasContent = null;
                    updated = true;
                    break;
                }
              }
            }
          } else {
            int timeUpdate = DateTime.fromMicrosecondsSinceEpoch(
                    da.date.microsecondsSinceEpoch)
                .millisecondsSinceEpoch;
            prefs.setInt(key, timeUpdate);
          }
        }
      }

      return updated;
    } catch (e) {
      print(e);
    }
  }*/
}

class Update {
  final UpdateType updateType;

  Update(this.updateType);

  factory Update.fromJson(Map<String, Object> doc, String docId) {
    List<UpdateTime> times = [];
    List<String> keys = [];
    int count = 0;
    for (var k in doc.keys) {
      keys.add(k);
    }
    for (var d in doc.values) {
      Timestamp time = d as Timestamp;
      String key = keys[count];
      UpdateTime updateTime = new UpdateTime(key, time);
      times.add(updateTime);
      count++;
    }
    UpdateType udateType = new UpdateType(docId, times);
    return new Update(udateType);
  }

  factory Update.fromDocument(DocumentSnapshot doc) {
    String documentID = doc.id;
    return Update.fromJson(doc.data(), documentID);
  }
}
