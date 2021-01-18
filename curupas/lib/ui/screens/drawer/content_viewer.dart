import 'dart:async';
import 'dart:convert';
import 'package:curupas/models/HTML.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

//https://pub.dev/packages/webview_media#-example-tab-

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

  WebViewController webViewController;
  String htmlFilePath = 'assets/html/drawer_base.html';
  bool _isLoadingPage = true;

  loadLocalHTML() async {
    String fileHtmlContents = await rootBundle.loadString(htmlFilePath);
    String html_content =
        fileHtmlContents.replaceFirst("replace", contentHtml.html);
    webViewController.loadUrl(Uri.dataFromString(html_content,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contentHtml.name)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(223, 0, 9, 1),
        child: Icon(
          Icons.share,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.80,
              child: Stack(
                children: <Widget>[
                  WebView(
                    initialUrl: '',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController tmp) {
                      webViewController = tmp;
                      loadLocalHTML();
                    },
                    onPageFinished: (finish) {
                      setState(() {
                        _isLoadingPage = false;
                      });
                    },
                  ),
                  _isLoadingPage
                      ? Center(child: CircularProgressIndicator())
                      : Container(),
                ],
              ),
            ),
            Container(
            )
          ],
        ),
      ),
    );
  }
}
