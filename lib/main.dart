import 'dart:async';
import 'dart:math';

import 'package:Timer/Cards/TimesUpCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Entities.dart';
import 'Pages/LoginPage.dart';
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
    var durationHoursEditText = TimesUpEditText(
      textEditingController: TextEditingController(text: "0"),
      maxLength: 2,
      inputType: TextInputType.number,
    );
    var durationMinutesEditText = TimesUpEditText(
      textEditingController: TextEditingController(text: "0"),
      maxLength: 2,
      inputType: TextInputType.number,
    );
    var durationSecondsEditText = TimesUpEditText(
      textEditingController: TextEditingController(text: "0"),
      maxLength: 2,
      inputType: TextInputType.number,
    );
    var sessionsEditText = TimesUpEditText(
      textEditingController: TextEditingController(text: "1"),
      maxLength: 2,
      inputType: TextInputType.number,
    );
    var restHoursEditText = TimesUpEditText(
      textEditingController: TextEditingController(text: "0"),
      maxLength: 2,
      inputType: TextInputType.number,
    );
    var restMinutesEditText = TimesUpEditText(
      textEditingController: TextEditingController(text: "0"),
      maxLength: 2,
      inputType: TextInputType.number,
    );
    var restSecondsEditText = TimesUpEditText(
      textEditingController: TextEditingController(text: "0"),
      maxLength: 2,
      inputType: TextInputType.number,
    );
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(
                "I'm your new timer, set me up!",
                style: TextStyle(fontFamily: "Nunito"),
              ),
              scrollable: true,
              content: Column(children: [
                Text('Duration'),
                EditTextItem(title: 'Name: ', editText: nameEditText),
                EditTextItem(title: 'Hours: ', editText: durationHoursEditText),
                EditTextItem(
                    title: 'Minutes: ', editText: durationMinutesEditText),
                EditTextItem(
                    title: 'Seconds: ', editText: durationSecondsEditText),
                EditTextItem(title: 'Sessions: ', editText: sessionsEditText),
                Text('Rest'),
                EditTextItem(title: 'Hours: ', editText: restHoursEditText),
                EditTextItem(title: 'Minutes: ', editText: restMinutesEditText),
                EditTextItem(title: 'Seconds: ', editText: restSecondsEditText),
              ]),
              actions: [
                FlatButton(
                    onPressed: () {
                      addItem(
                          widget.user.email,
                          Item(
                              id: Random().nextInt(1000000),
                              name: nameEditText.textEditingController.text,
                              sessionDuration: calcutateTimeInMillis(
                                  int.parse(durationHoursEditText
                                      .textEditingController.text),
                                  int.parse(durationMinutesEditText
                                      .textEditingController.text),
                                  int.parse(durationSecondsEditText
                                      .textEditingController.text)),
                              sessions: int.parse(
                                  sessionsEditText.textEditingController.text),
                              restDuration: calcutateTimeInMillis(
                                  int.parse(restHoursEditText
                                      .textEditingController.text),
                                  int.parse(
                                      restMinutesEditText.textEditingController.text),
                                  int.parse(restSecondsEditText.textEditingController.text)),
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
      listTimer.add(
          TimesUpCard(myHomePageState: this, user: widget.user, item: item));
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
    setState(() => listTimer.removeWhere(
        (e) => !items.map((item) => item.id).toList().contains(e.item.id)));
  }

  int calcutateTimeInMillis(int hours, int minutes, int seconds) {
    return (hours * 60 * 60 * 1000) + (minutes * 60 * 1000) + (seconds * 1000);
  }
}

class EditTextItem extends StatelessWidget {
  final String title;
  final TimesUpEditText editText;

  EditTextItem({this.title, this.editText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Flexible(
            child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            color: TimesUpColors().royalBlue,
          ),
        )),
        Flexible(child: editText),
      ],
    );
  }
}
