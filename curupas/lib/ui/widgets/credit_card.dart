

  import 'package:curupas/models/credit_card.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_credit_card/credit_card_model.dart';
  import 'package:flutter_credit_card/credit_card_widget.dart';
  import 'package:flutter_credit_card/flutter_credit_card.dart';

  class CreditCardEdit extends StatefulWidget {

    final CreditCard creditCard;

    CreditCardEdit({Key key, @required this.creditCard }) : super(key: key);

    @override
    _CreditCardEditState createState() => _CreditCardEditState();
  }

  class _CreditCardEditState extends State<CreditCardEdit> {

    String cardNumber = '';
    String expiryDate = '';
    String cardHolderName = '';
    String cvvCode = '';
    bool isCvvFocused = false;

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Flutter Credit Card View Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                CreditCardWidget(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: CreditCardForm(
                      onCreditCardModelChange: onCreditCardModelChange,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    void onCreditCardModelChange(CreditCardModel creditCardModel) {
      setState(() {
        cardNumber = creditCardModel.cardNumber;
        //expiryDate = creditCardModel.expiryDate;
        //cardHolderName = creditCardModel.cardHolderName;
        //cvvCode = creditCardModel.cvvCode;
        //isCvvFocused = creditCardModel.isCvvFocused;
      });
    }
  }