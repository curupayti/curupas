
import 'package:flutter/material.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class StaggeredWidget extends StatelessWidget {

  final double gridheight;

  StaggeredWidget(this.gridheight);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: gridheight,
      child:
      Scaffold(
      backgroundColor: Color.fromRGBO(255, 0, 0, 0),
      appBar:
      PreferredSize(
        preferredSize: Size.fromHeight(30.0), // here the desired height
        child:AppBar(
          centerTitle: true,
          backgroundColor: Color.fromRGBO(255, 0, 0, 0),
          title: Text('Fotos y videos',
            style: TextStyle(color: Colors.white,
                fontSize: 20.0),),
        ),
      ),
      body: Stack(
        children: <Widget>[
          _getStagged(),
        ],
      ),
      ),
    );
  }

  Widget _getStagged() {
    return StaggeredGridView.countBuilder(
      padding:
      const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0, bottom: 8.0),
      crossAxisCount: 4,
      itemCount: _globals.group.medias.length,
      itemBuilder: (context, j) {
        bool isVideo = false;
        String imgPath = _globals.group.medias[j].thumbnailUrl;
        String title = _globals.group.medias[j].title;
        String description = _globals.group.medias[j].description;
        if (_globals.group.medias[j].type == 1) {
          isVideo = true;
        }
        return new Card(
          child: new Column(
            children: <Widget>[
              new Center(
                child:
                Stack(
                  children: <Widget>[
                    new Image.network(imgPath),
                    Visibility(
                      visible: isVideo,
                      child: IconButton(
                        icon: Icon(
                          Icons.play_circle_outline,
                          size: 60.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(4.0),
                child: new Column(
                  children: <Widget>[
                    new Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    new Text(
                      description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
      staggeredTileBuilder: (j) =>
      new StaggeredTile.fit(2),
      mainAxisSpacing: 10.0,
      crossAxisSpacing: 10.0,
    );
  }
}
