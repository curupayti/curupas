import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:curupas/business/auth.dart';
import 'package:curupas/business/validator.dart';
import 'package:curupas/models/sms.dart';
import 'package:curupas/ui/widgets/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:curupas/globals.dart' as _globals;

import 'flat_button.dart';

class SMSDialog extends StatefulWidget {

  final String userId;
  final String phone;

  const SMSDialog({Key key, this.userId, this.phone}) : super(key: key);

  @override
  _SMSDialogState createState() => _SMSDialogState();
}

class _SMSDialogState extends State<SMSDialog> {
  final TextEditingController _smsGroup = new TextEditingController();
  CustomTextField _smsTextField;
  FocusNode phoneNumberFocusNodeGroup = new FocusNode();
  CustomFlatButton _resendSMSButton;

  TextSpan _messageText;
  String _messageInit = "Código";
  String _messageToShow;
  TextStyle _messageStyle;
  bool validated = false;
  bool _resendVisibility = true;

  bool _isSendingSMS = false;

  CircularProgressIndicator _circularProgressIndicator;

  SharedPreferences prefs;

  SMS sms;

  int countFails = 0;

  TextEditingController _textFieldController = TextEditingController();

  String _phone;

  @override
  void initState() {
    super.initState();

    _phone = widget.phone;

    /*Auth.getUserDataForSMS("Pf64W2FdPmOONv5dIefw9lmFmVY2").then((smsUser) {
        sms = smsUser;
      });*/

    //KeyboardVisibilityNotification().addNewListener(
    //  onChange: (bool visible) {

    Auth.getUserDataForSMS(widget.userId).then((smsUser) {
      sms = smsUser;
      _phone = sms.phone;
      _textFieldController.text = _phone;
    });

    try {

      KeyboardVisibility.onChange.listen(
        (bool visible) {
          setState(() {
            if (visible) {
              _resendVisibility = false;
            } else {
              _resendVisibility = true;
              Duration d = new Duration();
              sleep(new Duration(seconds: 2));
              if (!validated) {
                _messageToShow = _messageInit;
              }
              _messageStyle = TextStyle(
                  color: Colors.green, fontSize: ScreenUtil().setSp(50.0));
              initMessage();
              _smsGroup.clear();
            }
          });
        },
      );

    } on Exception catch (error) {
      print(error.toString());
    }

    _messageToShow = _messageInit;

    _messageStyle =
        TextStyle(color: Colors.green, fontSize: ScreenUtil().setSp(40.0));
    initMessage();

    _smsTextField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _smsGroup,
      maxLength: 4,
      style: new TextStyle(
        fontSize: 25.0,
        height: 1.5,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      hint: "Ingresa el código",
      inputType: TextInputType.number,
      validator: Validator.validateShortNumber,
      focusNode: phoneNumberFocusNodeGroup,
      onChanged: (String text) {
        if ((text.length != null) && text.length > 3) {
          var code = int.parse(text);
          setState(() {
            if (code == sms.smsCode) {
              _messageToShow = "Correcto";
              _messageStyle = TextStyle(
                  color: Colors.green, fontSize: ScreenUtil().setSp(50.0));
              initMessage();
              validated = true;
              FocusScope.of(context).requestFocus(FocusNode());
              prefs.setBool('smsvalidated', true);
              Map<String, dynamic> data = <String, dynamic>{'smsChecked': true};

              bool guest = (prefs.getBool('guest') ?? false);
              String page;

              if (guest) {
                page = "/main";
              } else {
                page = "/group";
              }

              Auth.updateUser(sms.userId, data).then((user) async {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    page, (Route<dynamic> route) => false);
              });


            } else {
              _messageToShow = "Incorrecto";
              _messageStyle = TextStyle(
                  color: Colors.red, fontSize: ScreenUtil().setSp(50.0));
              initMessage();
              validated = false;
              if (countFails == 2) {
                _resendVisibility = true;
                //_resendButtonEnabled(true);
                _smsGroup.text = sms.phone;
              }
              _smsGroup.clear();
              countFails++;
              FocusScope.of(context).requestFocus(FocusNode());
            }
          });
        } else {
          _messageToShow = _messageInit;
          _messageStyle = TextStyle(
              color: Colors.green, fontSize: ScreenUtil().setSp(50.0));
          initMessage();
        }
      },
    );

    _resendButtonEnabled(true);
    //_setNextButtonEnabled(false);

    getPrefs();
  }

  void getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  /*void _setNextButtonEnabled(bool enabled) {
      Color color, borderColor, textColor;
      if (enabled) {
        color = Color.fromRGBO(59, 89, 152, 1.0);
        borderColor = Color.fromRGBO(59, 89, 152, 1.0);
        textColor = Colors.white;
      } else {
        color = Colors.black26;
        borderColor = Colors.black54;
        textColor = Colors.black26;
      }
      _nextButton = CustomFlatButton(
        title: "Siguiente",
        enabled: enabled,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        textColor: textColor,
        onPressed: () {
          prefs.setBool('smsvalidated', true);
          Navigator.of(context).pushNamed("/group");
        },
        splashColor: Colors.black12,
        borderColor: borderColor,
        borderWidth: 0,
        color: color,
      );
    }*/

  void initMessage() {
    _messageText = new TextSpan(
      text: _messageToShow,
      style: _messageStyle,
    );
  }

  void _resendButtonEnabled(bool enabled) {
    Color color, borderColor, textColor;
    if (enabled) {
      color = Color.fromRGBO(59, 89, 152, 1.0);
      borderColor = Color.fromRGBO(59, 89, 152, 1.0);
      textColor = Colors.white;
    } else {
      color = Colors.black26;
      borderColor = Colors.black54;
      textColor = Colors.black26;
    }
    _resendSMSButton = CustomFlatButton(
      title: "Reenviar",
      enabled: enabled,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      textColor: textColor,
      onPressed: () {
        setState(() {
          _isSendingSMS = true;
          _reSendSMS();
        });

      },
      splashColor: Colors.black12,
      borderColor: borderColor,
      borderWidth: 0,
      color: color,
    );

    _circularProgressIndicator = new CircularProgressIndicator();

  }


  @override
  void dispose() {
    phoneNumberFocusNodeGroup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
        onWillPop: _onBackPressed,
        child: new AlertDialog(
        title:
        new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("+549${_phone}",
                style: TextStyle(
                    color: Colors.blue, fontSize: ScreenUtil().setSp(40.0))),
              Spacer(),
              IconButton(
                icon: Icon(Icons.edit),
                tooltip: 'Editar',
                onPressed: () {
                  setState(() {
                    _displayDialog(context);
                  });
                },
              ),
            ],
          ),
          content: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: new RichText(
                  text: _messageText,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: _smsTextField,
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Visibility(
                  visible: _resendVisibility,
                  child: _resend(context),
                ),
              ),
            ],
          ),
    ));
    /*actions: <Widget>[
          Padding(
            padding: const EdgeInsets,only(
                top: 5.0, right: 15.0, left: 15.0, bottom: 5.0),
            child: Visibility(
              visible: _nextVisible,
              child: _nextButton,
            ),
          ),
        ],
      );*/
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Numero de teléfono'),
            content: TextField(
              controller: _textFieldController,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(hintText: "Cambiar número"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Guardar'),
                onPressed: () {
                  var _phone_ = _textFieldController.text;
                  Auth.updateUserPhone(_phone_);
                  Navigator.of(context).pop();
                  _updatePhone(_phone_);
                },
              )
            ],
          );
        });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Información'),
        content: new Text('Es necesario que valides tu celular para poder utilizar la aplicación.'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text("Cerrar"),
          ),
          //SizedBox(height: 16),
          /*new GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Text("YES"),
          ),*/
        ],
      ),
    ) ??
        false;
  }

  Widget _resend(BuildContext context) {
      return Stack(children: <Widget>[
        new Container(
          child: new Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            Row(
              children: [
                _resendSMSButton,
                SizedBox(width: 20),
                _isSendingSMS == true ?
                _circularProgressIndicator: new Container(),
              ]
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: new Text(
                  "powered by",
                  softWrap: true,
                  textAlign: TextAlign.left,
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
                padding: const EdgeInsets.only(top: 5.0),
                child:
                  InkWell(
                    onTap: () {
                      _globals.launchURL("https://landing.notimation.com.ar/");
                    },
                    child:
                      Container(
                        child: Image.asset("assets/images/notimation.png"),
                      ),
                  ),
              ),
            ],
          ),
        ),
      ]);
    }

  void _reSendSMS() async {
    int code = await _globals.generateRandom();
    var message = _globals.getCodeMessgae(code);
    //String phone = _smsGroup.text;
    _globals.sendUserSMSVerification(_phone, message, sms.userId, code).then((bool resutl) =>
      _onSMSMessageResutl(resutl)
    );
  }

  Future<bool> _onSMSMessageResutl(bool resutl) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Envio SMS'),
        content:
        resutl == false || resutl == null ?
          new Text('No se pudo enviar el mensaje de texto, por favor volve a intentarlo mas tarde.')
        :new Text('Se envio un nuevo codigo de verificación correctamente.'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text("Cerrar"),
          ),
          //SizedBox(height: 16),
          /*new GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Text("YES"),
          ),*/
        ],
      ),
    ) ??
        false;
  }

  void _updatePhone(String phone) {
    setState(() {
      _phone = phone;
    });
  }

}

class DialogExample extends StatefulWidget {

  @override
  _DialogExampleState createState() => new _DialogExampleState();
}

class _DialogExampleState extends State<DialogExample> {
  String _text = "initial";
  TextEditingController _c;
  @override
  initState(){
    _c = new TextEditingController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(_text),
              new ElevatedButton(onPressed: () {
               return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      new Column(
                        children: <Widget>[
                          new TextField(
                            decoration: new InputDecoration(hintText: "Update Info"),
                            controller: _c,

                          ),
                          new TextButton(
                            child: new Text("Save"),
                            onPressed: (){
                              setState((){
                                this._text = _c.text;
                              });
                              Navigator.pop(context);
                            },
                          )
                        ],
                      );
                    });
              },child: new Text("Show Dialog"),)
            ],
          )
      ),
    );
  }
}
