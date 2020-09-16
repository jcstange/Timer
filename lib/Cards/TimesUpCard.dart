
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Sound.dart';
import '../Tick.dart';
import '../Repository.dart';
import '../TimesUpColors.dart';
import '../main.dart';
import '../Entities.dart';

class TimesUpCard extends StatefulWidget {
  String title;
  Item item;
  MyHomePageState myHomePageState;

  TimesUpCard({Key key, this.myHomePageState, this.item})
      : super(key: key);

  @override
  _TimesUpCardState createState() => _TimesUpCardState();
}

class _TimesUpCardState extends State<TimesUpCard> {
  DateTime start = DateTime.now();
  DateTime end;
  Duration remaining;
  Duration paused = Duration(milliseconds: 0);
  DateTime pauseStart;
  DateTime pauseEnd;
  Duration elapsed;
  StreamSubscription listenToSeconds;
  Sound sound;
  Future<int> soundId;
  bool ongoing = false;
  bool ended = false;

  @override
  void initState() {
    super.initState();
    getUsers()
        .then((value) => print("Repository Users -> ${value.toString()}"));
  }

  void startTimer() {
    if (listenToSeconds == null) {
      start = DateTime.now();
      var lastTime = DateTime.now();
      listenToSeconds = Tick().second.stream.listen((second) {
        setState(() {
          if (ongoing) {
            if (getRemainingTime().inMilliseconds <= 0) {
              endTimer();
              sound.playSound(soundId);
              ongoing = false;
              ended = true;
            }
          } else {
            var elapsedTime = DateTime.now().millisecondsSinceEpoch -
                lastTime.millisecondsSinceEpoch;
            paused = paused + Duration(milliseconds: elapsedTime);
          }
          lastTime = DateTime.now();
        });
      });
    }
  }

  void resetTimer() {
    paused = Duration(milliseconds: 0);
    ended = false;
    listenToSeconds.cancel();
    listenToSeconds = null;
  }

  void endTimer() {
    end = DateTime.now();
  }

  void delete() {
    print("delete ${widget.item.name}");
    endTimer();
    if(listenToSeconds != null) listenToSeconds.cancel();
    widget.myHomePageState.deleteTimer(widget);
  }

  void play() {
    print("play");
    startTimer();
    sound = Sound();
    sound.init();
    soundId = sound.loadSound();
    ongoing = true;
    widget.item.startTime = DateTime.now().millisecondsSinceEpoch;
    updateItem("jcstange@gmail.com",widget.item);
  }

  void pause() {
    print("pause");
    pauseStart = DateTime.now();
    ongoing = false;
  }

  void replay() {
    resetTimer();
    play();
  }

  Duration getRemainingTime() {
    return Duration(
        milliseconds: widget.item.sessionDuration -
            (getElapsedTime().inMilliseconds - getPausedTime().inMilliseconds));
  }

  String getTimeString(Duration duration) {
    if (duration.isNegative) return "00";
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inMinutes >= 60) {
      return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
    } else if (duration.inSeconds >= 60) {
      return "$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitSeconds";
    }
  }

  Duration getElapsedTime() {
    return Duration(
        milliseconds: DateTime.now().millisecondsSinceEpoch -
            start.millisecondsSinceEpoch);
  }

  Duration getPausedTime() {
    return paused;
  }

  double percentageTimeLeft() {
    var totalTime = widget.item.sessionDuration;
    var percentage = (getRemainingTime().inMilliseconds / totalTime).toDouble();
    print(percentage);
    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ended
              ? TimesUpColors().blackChocolate
              : TimesUpColors().royalBlue,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Container(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: percentageTimeLeft(),
                      valueColor:
                      AlwaysStoppedAnimation<Color>(TimesUpColors().cerise),
                    )),
                Expanded(
                    child: Text(
                      getTimeString(getRemainingTime()),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: TimesUpColors().snow),
                    )),
              ],
            ),
            Expanded(
                flex: 5,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        widget.item.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: TimesUpColors().snow),
                      ),
                      Text(
                        getTimeString(Duration(milliseconds: widget.item.sessionDuration)),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: TimesUpColors().snow),
                      ),
                    ])),
            Expanded(
                flex: 2,
                child: FlatButton(
                    onPressed: () =>
                    ongoing ? pause() : ended ? replay() : play(),
                    child: Icon(
                      ongoing
                          ? Icons.pause_circle_filled
                          : ended ? Icons.replay : Icons.play_circle_filled,
                      color: TimesUpColors().snow,
                    ))),
            Expanded(
                flex: 2,
                child: FlatButton(
                    onPressed: () {
                      delete();
                      removeItem("jcstange@gmail.com",widget.item);
                    },
                    child: Icon(
                      Icons.delete_forever,
                      color: TimesUpColors().snow,
                    ))),
          ],
        ));
  }
}