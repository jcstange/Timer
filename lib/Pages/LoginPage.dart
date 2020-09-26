import 'dart:html';

import 'package:Timer/UIComponents/TimesUpEditText.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../Entities.dart';
import '../Repository.dart';
import '../TimesUpColors.dart';
import '../UIComponents/Storage.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController textEditingController =
      TextEditingController(text: "Email");
  var showValidationError = false;

  Future<User> loadUser(String email) {
    return getUser(email).then((value) {
      print("username: ${value.username}");
      return value;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      getStorageUser().then((email) {
        if (email != null) {
          loadUser(email).then((value) => goToMain(value));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title,
              style: TextStyle(fontSize: 16, fontFamily: 'Nunito')),
        ),
        backgroundColor: TimesUpColors().snow,
        body: Container(
            padding: EdgeInsets.all(25.0),
            child: Column(children: [
              Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text("To login, type your email",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 16, fontFamily: 'Nunito'))),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: TimesUpEditText(
                    textEditingController: textEditingController,
                    maxLength: 100,
                  )),
              Visibility(
                  visible: showValidationError,
                  child: Container(
                      child: Text("Oops... Are you sure this is an email address?",
                          style: TextStyle(
                            color: TimesUpColors().cerise,
                            fontFamily: 'Nunito',
                            fontSize: 12,
                          )))),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 15.0),
                child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    color: TimesUpColors().royalBlue,
                    onPressed: () {
                      if (validateEmail(textEditingController.text)) {
                        getUser(textEditingController.text)
                            .then((value) => goToMain(value))
                            .catchError((onError) {
                          print('My error is: $onError');
                          showDialog(
                              context: context,
                              builder: (_) => createAccountDialog());
                        });
                      } else {
                        setState(() {
                          showValidationError = true;
                        });
                      }
                    },
                    child: Text(
                      "SIGN UP / LOG IN",
                      style: TextStyle(
                        color: TimesUpColors().snow,
                        fontSize: 16,
                        fontFamily: 'Nunito',
                      ),
                    )),
              ),
            ])));
  }

  void goToMain(User user) {
    storeUser(user.email).then((value) {
      print("User stored");
    });
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(title: widget.title, user: user)));
  }

  AlertDialog createAccountDialog() {
    return AlertDialog(
        title: Text(
            "Account not found, would you like to create an account for ${textEditingController.text}",
            style: TextStyle(fontSize: 16, fontFamily: 'Nunito')),
        content: RaisedButton(
            onPressed: () => addUser(textEditingController.text)
                .then((value) => goToMain(value)),
            child: Text('Create Account',
                style: TextStyle(
                  color: TimesUpColors().snow,
                  fontSize: 16,
                  fontFamily: 'Nunito',
                ))));
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  void main() {
    print(validateEmail("aslam@gmail.com"));
  }
}
