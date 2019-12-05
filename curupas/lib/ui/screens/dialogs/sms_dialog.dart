import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onboarding_flow/business/auth.dart';
import 'package:onboarding_flow/business/validator.dart';
import 'package:onboarding_flow/ui/widgets/custom_flat_button.dart';
import 'package:onboarding_flow/ui/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SMSDialog extends StatefulWidget {
  @override
  _SMSDialogState createState() => _SMSDialogState();
}

class _SMSDialogState extends State<SMSDialog> {
  final TextEditingController _smsGroup = new TextEditingController();
  CustomTextField _smsGroupField;
  FocusNode phoneNumberFocusNodeGroup = new FocusNode();
  CustomFlatButton _saveSMSButton;

  bool _isNewGroupVisible = true;
  SharedPreferences prefs;

  int smsCode;

  @override
  void initState() {
    super.initState();

    Auth.getUserDataForSMS("Pf64W2FdPmOONv5dIefw9lmFmVY2").then((code) {
        smsCode = code;
    });

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
    _saveSMSButton = CustomFlatButton(
      title: "Guardar Camada",
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
      title: Text('Confimá número',
          style: TextStyle(
              color: Colors.blue, fontSize: ScreenUtil().setSp(40.0))),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
            child: Visibility(
              visible: _isNewGroupVisible,
              child: _smsGroupField,
            ),
          ),
          Spacer(),
          _buildAboutText(),
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

  Widget _buildAboutText() {
    return new RichText(
      text: new TextSpan(
        text:
            'Un mensaje SMS se ha sido enviado con un ccodigo que debes ingresar en la próxima pantalla.\n\n',
        style: TextStyle(
            color: Colors.black87, fontSize: ScreenUtil().setSp(30.0)),
        children: <TextSpan>[
          new TextSpan(
              text:
                  'Si no lo recibiste por favor ponete en contacto con el referente de tu camada.',
              style: TextStyle(
                  color: Colors.black87, fontSize: ScreenUtil().setSp(30.0))),
        ],
      ),
    );
  }

  void _saveGroup(BuildContext context) async {}
}
