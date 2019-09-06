import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_flow/models/description.dart';
import 'package:onboarding_flow/models/feeds.dart';
import 'package:onboarding_flow/models/group.dart';
import 'package:onboarding_flow/models/user.dart';
import 'package:youtube_api/youtube_api.dart';

import 'models/streaming.dart';

User user = new User();
Group group = new Group();
Description description = new Description();
List<Feed> feeds = new List<Feed>();
Data dataFeed;
Streammer streammer;

class Streammer {
  List<YT_API> ytResult = [];
  List<Streaming> streamings;
  bool _isLiveStreaming = false;
  IconData videoIcon;
  String showLivestreamingMessage;

  Streammer() {
    setIsLiveStreaming(false);
  }

  void setIsLiveStreaming(bool _isLive) {
    if (_isLive) {
      showLivestreamingMessage = "Transmisión en vivo";
      videoIcon = Icons.live_tv;
    } else {
      showLivestreamingMessage = "Video ya emitido";
      videoIcon = Icons.tv;
    }
    _isLiveStreaming = _isLive;
  }

  void setYtResutl(List<YT_API> _ytResult) {
    ytResult = _ytResult;
  }

  void serStreamings(List<Streaming> _streamings) {
    streamings = _streamings;
  }
}

void setYoutubeApi(List<YT_API> _ytResult) {
  streammer = new Streammer();
  streammer.setYtResutl(_ytResult);
}

void setDataFeed(String desc, List<Feed> feeds) {
  dataFeed = new Data(
    name: 'Curupa',
    avatar: 'assets/images/escudo.png',
    backdropPhoto: 'assets/images/cancha.png',
    location: 'Hurlingham, Buenos Aires',
    biography: desc,
    feeds: feeds,
    /*<Feeds>[
      Video(
        title: 'Free - Mr. Big - Live at Granada Studios 1970',
        thumbnail: 'assets/images/test.png',
        url: 'https://www.youtube.com/watch?v=_FhCilozomo',
      ),
      Video(
        title: 'Free - Ride on a Pony - Live at Granada Studios 1970',
        thumbnail: 'assets/images/test.png',
        url: 'https://www.youtube.com/watch?v=EDHNZuAnBoU',
      ),
      Video(
        title: 'Free - Songs of Yesterday - Live at Granada Studios 1970',
        thumbnail: 'assets/images/test.png',
        url: 'https://www.youtube.com/watch?v=eI1FT0a_bos',
      ),
      Video(
        title: 'Free - I\'ll Be Creepin\' - Live at Granada Studios 1970',
        thumbnail: 'assets/images/test.png',
        url: 'https://www.youtube.com/watch?v=3qK8O3UoqN8',
      ),
    ],*/
  );
}

/*void setDataVideo(String desc, List<Feed> feeds) {
  dataVideo = new Data(
    name: 'Curupa',
    avatar: 'assets/images/escudo.png',
    backdropPhoto: 'assets/images/cancha.png',
    location: 'Hurlingham, Buenos Aires',
    biography: desc,
    videos: <Feeds>[
      Video(
        title: 'Free - Mr. Big - Live at Granada Studios 1970',
        thumbnail: 'assets/images/test.png',
        url: 'https://www.youtube.com/watch?v=_FhCilozomo',
      ),
      Video(
        title: 'Free - Ride on a Pony - Live at Granada Studios 1970',
        thumbnail: 'assets/images/test.png',
        url: 'https://www.youtube.com/watch?v=EDHNZuAnBoU',
      ),
      Video(
        title: 'Free - Songs of Yesterday - Live at Granada Studios 1970',
        thumbnail: 'assets/images/test.png',
        url: 'https://www.youtube.com/watch?v=eI1FT0a_bos',
      ),
      Video(
        title: 'Free - I\'ll Be Creepin\' - Live at Granada Studios 1970',
        thumbnail: 'assets/images/test.png',
        url: 'https://www.youtube.com/watch?v=3qK8O3UoqN8',
      ),
    ],
  );
}*/

class Data {
  Data({
    @required this.name,
    @required this.avatar,
    @required this.backdropPhoto,
    @required this.location,
    @required this.biography,
    @required this.feeds,
  });

  final String name;
  final String avatar;
  final String backdropPhoto;
  final String location;
  final String biography;
  final List<Feed> feeds;
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
