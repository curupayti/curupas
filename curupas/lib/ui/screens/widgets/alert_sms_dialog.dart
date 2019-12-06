import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onboarding_flow/business/auth.dart';
import 'package:onboarding_flow/business/validator.dart';
import 'package:onboarding_flow/ui/screens/widgets/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

import 'flat_button.dart';

class SMSDialog extends StatefulWidget {
  @override
  _SMSDialogState createState() => _SMSDialogState();
}

class _SMSDialogState extends State<SMSDialog> {
  final TextEditingController _smsGroup = new TextEditingController();
  CustomTextField _smsGroupField;
  FocusNode phoneNumberFocusNodeGroup = new FocusNode();
  CustomFlatButton _resendSMSButton;

  TextSpan _messageText;
  String _messageToShow;
  TextStyle _messageStyle;
  //bool _messageVisibility = true;
  //bool _descriptionVisibility = true;

  bool _isNewGroupVisible = true;
  SharedPreferences prefs;

  int smsCode;

  @override
  void initState() {
    super.initState();

    Auth.getUserDataForSMS("Pf64W2FdPmOONv5dIefw9lmFmVY2").then((code) {
      smsCode = code;
    });

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          if (visible) {
            //_messageVisibility = false;
            //_descriptionVisibility = true;
          } else {
            //_messageVisibility = true;
            //_descriptionVisibility = false;
          }
        });
      },
    );

    _messageStyle =
        TextStyle(color: Colors.green, fontSize: ScreenUtil().setSp(50.0));

    _messageText = new TextSpan(
      text: "Ingresa numeros del sms",
      style: _messageStyle,
    );

    _smsGroupField = new CustomTextField(
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
      onChanged: (int code) {
        if (code.toString().length != null) {
          setState(() {
            //_messageVisibility = true;
            if (code == smsCode) {
              _messageToShow = "Validación correcta";
              _messageStyle = TextStyle(
                  color: Colors.green, fontSize: ScreenUtil().setSp(50.0));
            } else {
              _messageToShow = "Validación incorrecta";
              _messageStyle = TextStyle(
                  color: Colors.red, fontSize: ScreenUtil().setSp(50.0));
            }
          });
        }
      },
    );

    _setButtonEnabled(false);
  }

  void _setButtonEnabled(bool enabled) {
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
        _saveGroup(context);
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
      title: Text('Confimá código',
          style: TextStyle(
              color: Colors.blue, fontSize: ScreenUtil().setSp(50.0))),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: new RichText(
              text: _messageText,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: _smsGroupField,
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: _resendSMSButton,
          ),
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 5.0, right: 15.0, left: 15.0),
          child: new FlatButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/group");
            },
            textColor: Colors.white,
            child: Text(
              'SIGUIENTE',
              style: TextStyle(
                  color: Colors.blue, fontSize: ScreenUtil().setSp(40.0)),
            ),
          ),
        ),
      ],
    );
  }

  /*Widget _buildDescriptionText() {
    return Visibility(
      visible: _descriptionVisibility,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: new RichText(
            text: new TextSpan(
              text: 'Ingresa el codigo del SMS.\n\n',
              style: TextStyle(
                  color: Colors.black87, fontSize: ScreenUtil().setSp(50.0)),
            ),
          ),
        ),
      ]),
    );
  }*/

  void _saveGroup(BuildContext context) async {}
}
