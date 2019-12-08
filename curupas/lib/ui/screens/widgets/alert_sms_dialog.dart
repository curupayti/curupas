import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onboarding_flow/business/auth.dart';
import 'package:onboarding_flow/business/validator.dart';
import 'package:onboarding_flow/models/sms.dart';
import 'package:onboarding_flow/ui/screens/widgets/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:onboarding_flow/globals.dart' as _globals;

import 'flat_button.dart';

class SMSDialog extends StatefulWidget {
  final String userId;

  const SMSDialog({Key key, this.userId}) : super(key: key);

  @override
  _SMSDialogState createState() => _SMSDialogState();
}

class _SMSDialogState extends State<SMSDialog> {
  final TextEditingController _smsGroup = new TextEditingController();
  CustomTextField _smsTextField;
  FocusNode phoneNumberFocusNodeGroup = new FocusNode();
  CustomFlatButton _resendSMSButton;

  TextSpan _messageText;
  String _messageInit = "Ingresa codigo";
  String _messageToShow;
  TextStyle _messageStyle;
  bool validated = false;
  bool _resendVisibility = true;

  bool _isNewGroupVisible = true;
  bool _nextVisible = true;
  SharedPreferences prefs;

  SMS sms;

  CustomFlatButton _nextButton;

  int countFails = 0;

  @override
  void initState() {
    super.initState();

    Auth.getUserDataForSMS(widget.userId).then((smsUser) {
      sms = smsUser;
    });

    /*Auth.getUserDataForSMS("Pf64W2FdPmOONv5dIefw9lmFmVY2").then((smsUser) {
      sms = smsUser;
    });*/

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          if (visible) {
            _resendVisibility = false;
            _nextVisible = false;
          } else {
            Duration d = new Duration();
            sleep(new Duration(seconds: 2));
            if (validated) {
              _nextVisible = true;
            } else {
              _messageToShow = _messageInit;
              _resendVisibility = true;
            }
            _messageStyle = TextStyle(
                color: Colors.green, fontSize: ScreenUtil().setSp(50.0));
            initMessage();
            _smsGroup.clear();
          }
        });
      },
    );

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
      hint: "Ingresa el códifo",
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
              _resendButtonEnabled(false);
              _setNextButtonEnabled(true);
              FocusScope.of(context).requestFocus(FocusNode());
            } else {
              _messageToShow = "Incorrecto";
              _messageStyle = TextStyle(
                  color: Colors.red, fontSize: ScreenUtil().setSp(50.0));
              initMessage();
              validated = false;
              if (countFails == 2) {
                _resendButtonEnabled(true);
                _smsGroup.text = sms.phone;
              }
              _setNextButtonEnabled(false);
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

    _resendButtonEnabled(false);
    _setNextButtonEnabled(false);

    getPrefs();
  }

  void getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _setNextButtonEnabled(bool enabled) {
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
  }

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
      title: "Reenviar codigo",
      enabled: enabled,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      textColor: textColor,
      onPressed: () {
        _reSendSMS();
      },
      splashColor: Colors.black12,
      borderColor: borderColor,
      borderWidth: 0,
      color: color,
    );
  }

  @override
  void dispose() {
    phoneNumberFocusNodeGroup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Text('Código SMS',
          style: TextStyle(
              color: Colors.blue, fontSize: ScreenUtil().setSp(50.0))),
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
              child: _resendSMSButton,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
              top: 5.0, right: 15.0, left: 15.0, bottom: 5.0),
          child: Visibility(
            visible: _nextVisible,
            child: _nextButton,
          ),
        ),
      ],
    );
  }

  void _reSendSMS() async {
    int code = await _globals.generateRandom();
    var message = _globals.getCodeMessgae(code);
    String phone = _smsGroup.text;
    _globals.sendUserSMSVerification(phone, message, sms.userId, code);
  }
}
