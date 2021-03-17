import 'package:curupas/models/streaming.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Streammer {
  List<Streaming> streamings = [];
  bool _isLiveStreaming = false;
  IconData videoIcon;
  String showLivestreamingMessage;
  Streaming activeStreaming;

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

  void serStreamings(List<Streaming> _streamings) {
    activeStreaming = _streamings[0];
    streamings = _streamings;
  }
}
