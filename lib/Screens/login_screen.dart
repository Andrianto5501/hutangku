import 'package:flutter/material.dart';
import 'package:hutangku/constants.dart';
import 'package:hutangku/Widget/login_form.dart';
import 'package:hutangku/Components/circleLogo.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode _uidFocusNode = FocusNode();

  // Future<FirebaseApp> _initializeFirebase() async {
  //   FirebaseApp firebaseApp = await Firebase.initializeApp();

  //   return firebaseApp;
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _uidFocusNode.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.blue,
        appBar: AppBar(
            title: Text(
              'Hutangku App',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor),
            ),
            centerTitle: true,
            elevation: 0,
            automaticallyImplyLeading: false),
        body: SafeArea(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 30),
                margin: EdgeInsets.only(top: 100),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                ),
                child: Flex(direction: Axis.vertical, children: <Widget>[
                  circleLogo(),
                  Container(
                      transform: Matrix4.translationValues(0.0, -70.0, 0.0),
                      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                      child: LoginForm(focusNode: _uidFocusNode)),
                ]),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
