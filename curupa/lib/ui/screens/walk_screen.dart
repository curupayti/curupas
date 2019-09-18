import 'package:flutter/material.dart';
import "package:flutter_swiper/flutter_swiper.dart";
import "package:onboarding_flow/models/walkthrough.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onboarding_flow/ui/widgets/custom_flat_button.dart';

class WalkthroughScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final List<Walkthrough> pages = [
    Walkthrough(
      image: "assets/images/escudo.png",
      title: "Curupa",
      description: "Construyendo una base de datos de socios y ex jutadores",
    ),
    /*Walkthrough(
      image: "assets/images/curupa_anexo.png",
      title: "San Jorge",
      description: "Pensando en San Jorge y camadas",
    ),*/
  ];

  WalkthroughScreen({this.prefs});

  @override
  _WalkthroughScreenState createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Swiper.children(
        autoplay: false,
        index: 0,
        loop: false,
        pagination: new SwiperPagination(
          margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
          builder: new DotSwiperPaginationBuilder(
              color: Colors.white30,
              activeColor: Colors.white,
              size: 6.5,
              activeSize: 8.0),
        ),
        control: SwiperControl(
          iconPrevious: null,
          iconNext: null,
        ),
        children: _getPages(context),
      ),
    );
  }

  List<Widget> _getPages(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i < widget.pages.length; i++) {
      Walkthrough page = widget.pages[i];

      double _width = 0;

      if (i == 0) {
        _width = 400.0;
      } else if (i == 1) {
        _width = 300.0;
      }

      widgets.add(
        new Container(
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(top: 100.0, left: 30.0, right: 30.0),
                child: new Image.asset(page.image,
                    height: _width, width: 100.0, fit: BoxFit.cover),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 50.0, right: 15.0, left: 15.0),
                child: Text(
                  page.title,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                    fontSize: 50.0,
                    fontWeight: FontWeight.w700,
                    fontFamily: "OpenSans",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  page.description,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w300,
                    fontFamily: "OpenSans",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: page.extraWidget,
              )
            ],
          ),
        ),
      );
    }
    widgets.add(
      new Container(
        color: Colors.white, //fromRGBO(212, 20, 15, 1.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.code,
                size: 125.0,
                color: Color.fromRGBO(0, 29, 126, 1.0),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 50.0, right: 15.0, left: 15.0),
                child: Text(
                  "Ingresa a la aplicacion o registrate.",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                    fontFamily: "OpenSans",
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 20.0, right: 15.0, left: 15.0),
                child: CustomFlatButton(
                  title: "Iniciar",
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  textColor: Colors.grey,
                  onPressed: () {
                    widget.prefs.setBool('seen', true);
                    Navigator.of(context).pushNamed("/root");
                  },
                  splashColor: Colors.black12,
                  borderColor: Colors.white,
                  borderWidth: 2,
                  color: Color.fromRGBO(191, 4, 17, 1.0),
                  enabled: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return widgets;
  }
}
