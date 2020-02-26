import 'package:curupas/models/HTML.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';


class ContentViewer extends StatelessWidget {
  final HTML contentHtml;

  ContentViewer({Key key, @required this.contentHtml}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: new Uri.dataFromString(contentHtml.html, mimeType: 'text/html').toString(),
      hidden: false,
      withLocalUrl: true,
      withZoom: true, //change to true or false to use webview with zoom or not
      appBar: AppBar(title: Text(contentHtml.name)),
    );
  }
}