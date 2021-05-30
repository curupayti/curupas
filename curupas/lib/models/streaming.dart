import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/models/streaming_thumbnails.dart';
import 'package:curupas/models/streaming_video.dart';

class Streaming {
  final String id;
  final String title;
  final String channelId;
  final String playListId;
  final String description;
  List<StreamingVideo> videos;
  StreamingThumbnail thumbnail;

  /*Streaming.fromMap(Map<dynamic, dynamic> data)
      : title = data["title"],
        description = data["description"],
        thumbnailSmallUrl = data["thumbnailSmallUrl"],
        images = List.from(data['videos']);*/

  Streaming({
    this.id,
    this.title,
    this.channelId,
    this.playListId,
    this.description,
    this.videos,
    this.thumbnail,
  });

  factory Streaming.fromJson(Map<String, Object> doc,
      StreamingThumbnail thumbnail, List<StreamingVideo> videos) {
    Streaming streaming = new Streaming(
      id: doc['id'],
      title: doc['title'],
      channelId: doc['channelId'],
      playListId: doc['playListId'],
      description: doc['description'],
      videos: videos,
      thumbnail: thumbnail,
    );
    return streaming;
  }

  factory Streaming.fromDocument(DocumentSnapshot doc,
      StreamingThumbnail thumbnail, List<StreamingVideo> videos) {
    return Streaming.fromJson(doc.data(), thumbnail, videos);
  }

  void setGroupReference(DocumentReference ref) {}
}
