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
