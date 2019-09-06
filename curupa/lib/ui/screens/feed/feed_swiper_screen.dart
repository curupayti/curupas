import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:onboarding_flow/models/feeds.dart';

class FeedSwipeScreen extends StatefulWidget {
  Feed feed;

  FeedSwipeScreen({this.feed});

  @override
  _FeedSwipeScreenState createState() => _FeedSwipeScreenState();
}

class _FeedSwipeScreenState extends State<FeedSwipeScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text(widget.feed.title),
        ),
        body: new Swiper(
          itemBuilder: (BuildContext context, int index) {
            return new Image.network(
              widget.feed.images[index],
              fit: BoxFit.fill,
            );
          },
          indicatorLayout: PageIndicatorLayout.COLOR,
          autoplay: true,
          itemCount: widget.feed.images.length,
          pagination: new SwiperPagination(),
          control: new SwiperControl(),
        ));
  }
}
