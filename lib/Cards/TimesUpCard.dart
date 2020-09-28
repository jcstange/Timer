import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Entities.dart';
import '../Repository.dart';
import '../Sound.dart';
import '../Tick.dart';
import '../TimesUpColors.dart';
import '../main.dart';

class TimesUpCard extends StatefulWidget {
  String title;
  User user;
  Item item;
  MyHomePageState myHomePageState;

  TimesUpCard({
    Key key,
    this.user,
    this.myHomePageState,
    this.item
  }) : super(key: key);

  @override
  _TimesUpCardState createState() => _TimesUpCardState();
}

class _TimesUpCardState extends State<TimesUpCard> {
  DateTime start = DateTime.now();
  DateTime end;
  Duration remaining;
  Duration elapsed = Duration(milliseconds: 0);
  Duration totalDuration;
  DateTime lastTick = DateTime.now();
  StreamSubscription listenToSeconds;
  Sound sound;
  Future<int> soundId;
  bool ongoing = false;
  bool ended = false;
  int remainingSessions;
  bool resting = false;

  @override
  void initState() {
    super.initState();
    print("initState Card");
    totalDuration = Duration(milliseconds: widget.item.sessionDuration);
    remaining = totalDuration;
    remainingSessions = widget.item.sessions;
  }

  void startTimer() {
    if (listenToSeconds == null) {
      start = DateTime.now();
      listenToSeconds = Tick().second.stream.listen((_) {
        if (ongoing) {
          // If paused, this thing will continue counting
          if(DateTime.now().millisecondsSinceEpoch - lastTick.millisecondsSinceEpoch > 980) {
            setState(() {
              elapsed += Duration(milliseconds: 1000);
            });
            if (getRemainingTime().inMilliseconds <= 0) {
              if(remainingSessions > 1){
                if(widget.item.sessionDuration > 0) {
                  //Set it to rest mode
                  if(!resting){
                    totalDuration = Duration(milliseconds: widget.item.restDuration);
                    elapsed = Duration(milliseconds: 0);
                    sound.playSound(soundId);
                    setState(() {
                      resting = true;
                    });
                  } else {
                    totalDuration = Duration(milliseconds: widget.item.sessionDuration);
                    elapsed = Duration(milliseconds: 0);
                    sound.playSound(soundId);
                    setState(() {
                      resting = false;
                      remainingSessions -= 1;
                    });
                  }
                }
              } else {
                endTimer();
                sound.playSound(soundId);
                setState(() {
                  remainingSessions -= 1;
                  ongoing = false;
                  ended = true;
                });
              }
            }
          }
        }
        lastTick = DateTime.now();
      });
    }
  }

  void resetTimer() {
    ended = false;
    remaining = totalDuration;
    elapsed = Duration(milliseconds: 0);
    listenToSeconds.cancel();
    listenToSeconds = null;
  }

  void endTimer() {
    end = DateTime.now();
  }

  void delete() {
    print("delete ${widget.item.name}");
    endTimer();
    if (listenToSeconds != null) listenToSeconds.cancel();
    widget.myHomePageState.deleteTimer(widget);
  }

  void play() {
    print("play");
    if(listenToSeconds != null && listenToSeconds.isPaused) {
      print("resuming");
      listenToSeconds.resume();
    } else {
      startTimer();
      sound = Sound();
      sound.init();
      soundId = sound.loadSound();
      widget.item.startTime = DateTime.now().millisecondsSinceEpoch;
    }
    setState(() {
      ongoing = true;
    });
    //updateItem(widget.user.email, widget.item);
  }

  void pause() {
    setState(() {
      ongoing = false;
    });
    listenToSeconds.pause();
  }

  void replay() {
    resetTimer();
    play();
  }

  Duration getRemainingTime() {
    print('Elapsed: ${getElapsedTime().inMilliseconds}');
    remaining = Duration(milliseconds: totalDuration.inMilliseconds - getElapsedTime().inMilliseconds);
    return remaining;
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
    return elapsed;
  }

  double percentageTimeLeft() {
    var percentage = (getRemainingTime().inMilliseconds / totalDuration.inMilliseconds).toDouble();
    print(percentage);
    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal:16),
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ongoing ? TimesUpColors().bloom : ended ? TimesUpColors().rain : TimesUpColors().snow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Container(
                    width: 100,
                    height:100,
                    child: Stack(
                        alignment: Alignment.center,
                        children: <Widget> [
                          Container(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: percentageTimeLeft(),
                                valueColor: AlwaysStoppedAnimation<Color>(resting ? TimesUpColors().green : TimesUpColors().cerise),
                              )
                          ),
                          Text(
                            getTimeString(getRemainingTime()),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: ended ? TimesUpColors().snow : TimesUpColors().royalBlue),
                          ),
                          Positioned(
                            top: 18,
                            child: Text(
                              '$remainingSessions x',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: ended ? TimesUpColors().snow : TimesUpColors().royalBlue),
                            ),
                          ),
                        ])),
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
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ended ? TimesUpColors().snow : TimesUpColors().royalBlue),
                      ),
                      Text(
                        '${widget.item.sessions} x ${getTimeString(Duration(
                            milliseconds: widget.item.sessionDuration))}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ended ? TimesUpColors().snow : TimesUpColors().royalBlue),
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
                          : ended
                          ? Icons.replay
                          : Icons.play_circle_filled,
                      color: ended ? TimesUpColors().snow : TimesUpColors().royalBlue,
                    ))),
            Expanded(
                flex: 2,
                child: FlatButton(
                    onPressed: () {
                      delete();
                      removeItem(
                          widget.user.email,
                          widget.item
                      );
                    },
                    child: Icon(
                      Icons.delete_forever,
                      color: ended ? TimesUpColors().snow : TimesUpColors().royalBlue,
                    ))),
          ],
        ));
  }
}
