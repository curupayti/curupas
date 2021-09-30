import 'package:curupas/business/auth.dart';
import 'package:curupas/ui/widgets/flat_button.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 60.0),
            child: Icon(
              Icons.phone_iphone,
              color: Color.fromRGBO(0, 29, 126, 1.0),
              size: 125.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 35.0, right: 15.0, left: 15.0),
            child: Text(
              "Ingresa con usuario, Facebook o registrate",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey, //fromRGBO(212, 20, 15, 1.0),
                decoration: TextDecoration.none,
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                fontFamily: "OpenSans",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Vas a poder estar en contacto con vos, Curupa y tu camada.",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                decoration: TextDecoration.none,
                fontSize: 15.0,
                fontWeight: FontWeight.w300,
                fontFamily: "OpenSans",
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
            child: CustomFlatButton(
              enabled: true,
              title: "Ingresa",
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed("/signin");
              },
              splashColor: Colors.black12,
              borderColor: Color.fromRGBO(173, 163, 1, 1.0),
              borderWidth: 2,
              color: Color.fromRGBO(212, 20, 15, 1.0),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
            child: CustomFlatButton(
              enabled: true,
              title: "Registrate",
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed("/signup");
              },
              splashColor: Colors.black54,
              borderColor: Colors.black12,
              borderWidth: 2,
              color: Color.fromRGBO(0, 29, 126, 1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 14.0, horizontal: 40.0),
            child: CustomFlatButton(
              enabled: true,
              title: "Visitantes",
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed("/guest");
              },
              splashColor: Colors.black,
              borderColor: Color.fromRGBO(59, 89, 152, 1.0),
              borderWidth: 0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

}
