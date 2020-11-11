import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/models/streaming_thumbnails.dart';

class StreamingVideo {
  String id;
  String title;
  String description;
  String channelId;
  String channelTitle;
  String playlistId;
  String videoId;
  int position;
  bool isLive;
  StreamingThumbnail thumbnail;
  String publishedAt;

  StreamingVideo({
    this.id,
    this.title,
    this.description,
    this.channelId,
    this.channelTitle,
    this.playlistId,
    this.videoId,
    this.position,
    this.isLive,
    this.thumbnail,
    this.publishedAt,
  });

  factory StreamingVideo.fromJson(Map<String, Object> doc, StreamingThumbnail thumbnail) {
    StreamingVideo streamingVideo = new StreamingVideo(
      id: doc['id'],
      title: doc['title'],
      description: doc['description'],
      channelId: doc['channelId'],
      channelTitle: doc['channelTitle'],
      playlistId: doc['playlistId'],
      position: doc['position'],
      isLive: doc['isLive'],
      thumbnail:thumbnail,
    );
    return streamingVideo;
  }

  factory StreamingVideo.fromDocument(DocumentSnapshot doc, StreamingThumbnail thumbnail) {
    return StreamingVideo.fromJson(doc.data(), thumbnail);
  }

}