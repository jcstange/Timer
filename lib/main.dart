import 'dart:async';
import 'dart:math';

import 'package:Timer/Cards/TimesUpCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Entities.dart';
import 'Repository.dart';
import 'TimesUpColors.dart';
import 'UIComponents/TimesUpEditText.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimesUp',
      theme: ThemeData(
        primaryColor: TimesUpColors().blackChocolate,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(title: 'TimesUp'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.user}) : super(key: key);
  final String title;
  final User user;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  List<TimesUpCard> listTimer = [];

  @override
  void initState() {
    super.initState();
    parseItems(widget.user.items);
  }

  @override
  void reassemble() {
    super.reassemble();
    Future.delayed(Duration(milliseconds: 2000), () => loadUser());
  }

  Future<void> loadUser() {
    return getUser(widget.user.email).then((value) {
      print("username: ${value.username}");
      print("email: ${value.email}");
      print("items: ${value.items}");
      parseItems(value.items);
    });
  }

  void setUpDialog() {
    var nameEditText = TimesUpEditText(
        textEditingController: TextEditingController(text: "Default Timer"));
    var durationEditText = TimesUpEditText(
      textEditingController: TextEditingController(text: "5"),
      maxLength: 3,
      inputType: TextInputType.number,
    );
    showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: Text(
                "I'm your new timer, set me up!",
                style: TextStyle(fontFamily: "Nunito"),
              ),
              content:
              Column(children: <Widget>[nameEditText, durationEditText]),
              actions: [
                FlatButton(
                    onPressed: () {
                      addItem(
                          widget.user.email,
                          Item(
                              id: Random().nextInt(1000000),
                              name: nameEditText.textEditingController.text,
                              sessionDuration: int.parse(durationEditText
                                  .textEditingController.text) *
                                  60 *
                                  1000,
                              sessions: 1,
                              restDuration: 0,
                              startTime: 0,
                              endTime: 0));
                      Navigator.of(context).pop();
                      reassemble();
                    },
                    child: Text("Start")),
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel")),
              ],
            ),
        barrierDismissible: false);
  }

  void _addTimer(String title, Item item) {
    setState(() {
      listTimer.add(TimesUpCard(myHomePageState: this, item: item));
    });
  }

  void deleteTimer(TimesUpCard timer) {
    setState(() {
      print("deleting ${timer.title}");
      removeItem(widget.user.email, timer.item);
      reassemble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: TimesUpColors().cloud,
      body: Container(
          child: RefreshIndicator(
              onRefresh: () => loadUser(),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: listTimer.length,
                itemBuilder: (BuildContext context, int i) {
                  return listTimer[i];
                },
              ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setUpDialog(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void parseItems(List<Item> items) {
    if (items.isEmpty) {
      setState(() => listTimer.clear());
      return;
    }
    items.forEach((item) {
      if (!listTimer.map((e) => e.item.id).toList().contains(item.id)) {
        _addTimer(item.name, item);
      }
    });
    //Removing deleted timers
    var toDelete = listTimer.where(
            (e) => !items.map((item) => item.id).toList().contains(e.item.id));
    toDelete.forEach((element) {
      print("deleting ${element.item.id}");
    });
    setState(() =>
        listTimer.removeWhere(
                (e) =>
            !items.map((item) => item.id).toList().contains(e.item.id)));
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController textEditingController =
  TextEditingController(text: "Email");

  Future<User> loadUser(String email) {
    return getUser(email).then((value) {
      print("username: ${value.username}");
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.title,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Nunito'
              )
          ),
        ),
        backgroundColor: TimesUpColors().snow,
        body: Container(
            padding: EdgeInsets.all(25.0),
            child: Column(children: [
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                      "To login, type your email",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Nunito'
                      )
                  )
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: TimesUpEditText(
                    textEditingController: textEditingController,
                    maxLength: 100,
                  )
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 15.0),
                child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    color: TimesUpColors().royalBlue,
                    onPressed: () {
                      loadUser(textEditingController.text).then((value) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MyHomePage(
                                        title: widget.title, user: value)));
                      }).catchError((onError) {
                        print('My error is: $onError');
                        showDialog(
                            context: context,
                            builder: (_) =>
                                AlertDialog(
                                    title: Text(
                                        "Account not found, would you like to create an account for ${textEditingController.text}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Nunito'
                                        )
                                    ),
                                    content: RaisedButton(
                                        onPressed: () =>
                                            addUser(textEditingController.text)
                                                .then((value) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyHomePage(
                                                              title: widget.title,
                                                              user: value)
                                                  )
                                              );
                                            }),
                                        child: Text(
                                            'Create Account',
                                            style: TextStyle(
                                              color: TimesUpColors().snow,
                                              fontSize: 16,
                                              fontFamily: 'Nunito',
                                            )
                                        )
                                    )
                                )
                        );
                      });
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
            ]
            )
        )
    );
  }
}

