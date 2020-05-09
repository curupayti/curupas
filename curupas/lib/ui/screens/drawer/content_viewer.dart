
  import 'package:curupas/models/HTML.dart';
  import 'package:flutter/material.dart';
  //import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
  import 'package:webview_media/webview_flutter.dart';


  /*class ContentViewer extends StatelessWidget {
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
  }*/

  class ContentViewer extends StatefulWidget {
    final HTML contentHtml;

    ContentViewer({Key key, @required this.contentHtml}) : super(key: key);

    @override
    createState() => _WebViewContentViewer(this.contentHtml);
  }

  class _WebViewContentViewer extends State<ContentViewer> {
    HTML contentHtml;
    final _key = UniqueKey();
    _WebViewContentViewer(this.contentHtml);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(title:
          Text(contentHtml.name)),
          body: Column(
            children: [
              Expanded(
                  child: WebView(
                      key: _key,
                      javascriptMode: JavascriptMode.unrestricted,
                      initialUrl: contentHtml.name))
              ],
           ),
        );
    }

  }