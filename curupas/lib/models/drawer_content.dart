import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/models/content_html.dart';
import 'package:device_info/device_info.dart';
import 'package:intl/intl.dart';



class DrawerContent {
  final String name;
  final DateTime last_update;
  final List<ContentHtml> contents;


  DrawerContent.fromMap(Map<dynamic, dynamic> data)
      : name = data["name"],
        last_update = data["last_update"],
        contents = List.from(data['contents']);

  DrawerContent({
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

  /*DateTime parseTime(dynamic date) {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {

    }

    return Platform.isIOS ? (date as Timestamp).toDate() : (date as DateTime);
  }*/

  factory DrawerContent.fromJson(Map<String, Object> doc, List<ContentHtml> contents) {
    //var data = new DateTime();
    Timestamp timestamp = doc["last_update"] as Timestamp;
    var format = new DateFormat('d MMM, hh:mm a');
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    DrawerContent drawer = new DrawerContent(
      name: doc['name'],
      last_update: date,
      contents: contents,
    );
    return drawer;
  }

  factory DrawerContent.fromDocument(DocumentSnapshot doc, List<ContentHtml> contents) {
    return DrawerContent.fromJson(doc.data, contents);
  }

  void setGroupReference(DocumentReference ref) {}
}
