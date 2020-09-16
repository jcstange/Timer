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
      home: MyHomePage(title: 'TimesUp'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  List<TimesUpCard> listTimer = [];

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  void reassemble() {
    super.reassemble();
    Future.delayed(Duration(milliseconds: 2000), () => loadUser());
  }

  Future<void> loadUser() {
    return getUser("jcstange@gmail.com").then((value) {
      print("Repository Users -> $value");
      print("username: ${value.username}");
      print("email: ${value.email}");
      print("items: ${value.items}");
      parseItems(value.items);
    });
  }

  void setUpDialog() {
    print("setUpDialog");
    var nameEditText = TimesUpEditText(initialValue: "Default Timer");
    var durationEditText = TimesUpEditText(
      initialValue: "5",
      maxLength: 2,
      inputType: TextInputType.number,
    );
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("I'm your new timer, set me up!"),
              content:
                  Column(children: <Widget>[nameEditText, durationEditText]),
              actions: [
                FlatButton(
                    onPressed: () {
                      addItem(
                          "jcstange@gmail.com",
                          Item(
                              id: Random().nextInt(1000000),
                              name: nameEditText.state.initialValue,
                              sessionDuration: int.parse(
                                      durationEditText.state.initialValue) *
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
      removeItem("jcstange@gmail.com", timer.item);
      reassemble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
    if(items.isEmpty) {
      setState(() => listTimer.clear());
      return;
    }
    items.forEach((item) {
      if (!listTimer.map((e) => e.item.id).toList().contains(item.id)) {
        _addTimer(item.name, item);
      }
    });
    //Removing deleted timers
    var toDelete = listTimer.where((e) => !items.map((item) => item.id).toList().contains(e.item.id));
    toDelete.forEach((element) { print("deleting ${element.item.id}"); });
    setState(() =>
        listTimer.removeWhere((e) => !items.map((item) => item.id).toList().contains(e.item.id))
    );
  }
}
