import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/models/HTML.dart';
import 'package:device_info/device_info.dart';
import 'package:intl/intl.dart';

class HTMLS {

  final String name;
  final DateTime last_update;
  final List<HTML> contents;

  HTMLS.fromMap(Map<dynamic, dynamic> data)
      : name = data["name"],
        last_update = data["last_update"],
        contents = List.from(data['contents']);

  HTMLS({
    this.name,
    this.last_update,
    this.contents,
  });

  Map<String, Object> toJson() {
    return {
      'name': name,
      'last_update': last_update,
      'images': contents.toString(),
    };
  }

  factory HTMLS.fromJson(Map<String, Object> doc, List<HTML> contents) {

    Timestamp timestamp = doc["last_update"] as Timestamp;
    var format = new DateFormat('d MMM, hh:mm a');
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    HTMLS drawer = new HTMLS(
      name: doc['name'],
      last_update: date,
      contents: contents,
    );
    return drawer;
  }

  factory HTMLS.fromDocument(DocumentSnapshot doc, List<HTML> contents) {
    return HTMLS.fromJson(doc.data, contents);
  }

  void setGroupReference(DocumentReference ref) {}
}
