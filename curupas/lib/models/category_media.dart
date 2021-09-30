import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CatgoryMedia {
  String documentID;
  int type;
  bool approved;
  String title;
  String description;
  String thumbnailUrl;
  String userId;
  DateTime last_update;
  String videoUrl;
  String imageUrl;

  CatgoryMedia({
    this.documentID,
    this.type,
    this.approved,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.userId,
    this.last_update,
  });

  Map<String, Object> toJson() {
    return {
      'documentID': documentID,
      'type': type,
      'approved': approved,
      'title': title,
      'desc': description,
      'thumbnail': thumbnailUrl,
      'userId': userId,
      'video': videoUrl,
      'image': imageUrl
    };
  }

  factory CatgoryMedia.fromJson(Map<String, Object> doc, String documentID) {
    Timestamp timestamp = doc["last_update"] as Timestamp;
    var format = new DateFormat('d MMM, hh:mm a');
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(
        timestamp.millisecondsSinceEpoch);

    CatgoryMedia group = new CatgoryMedia(
      documentID: documentID,
      type: doc['type'],
      approved: doc['approved'],
      title: doc['title'],
      description: doc['desc'],
      thumbnailUrl: doc['thumbnail'],
      userId: doc['userId'],
      last_update: date,
    );
    if (group.type == 1) {
      group.videoUrl = doc['video'];
    } else if (group.type == 2) {
      group.imageUrl = doc['image'];
    }
    return group;
  }

  factory CatgoryMedia.fromDocument(DocumentSnapshot doc) {
    String documentId = doc.id;
    return CatgoryMedia.fromJson(doc.data(), documentId);
  }
}
