import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

void main() {
  runApp(MyApp());
}

class MyColors {
  Color royalBlue = Color(0xFF0A2463);
  Color tuftsBlue = Color(0xFF3E92CC);
  Color snow = Color(0xFFFFFAFF);
  Color cerise = Color(0xFFD8315B);
  Color blackChocolate = Color(0xFF1E1B18);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer',
      theme: ThemeData(
        primaryColor: MyColors().blackChocolate,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Timer List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<MyTimer> listTimer = [];

  @override
  void initState() {
    super.initState();
  }

  void setUpDialog() {
    print("setUpDialog");
    var nameEditText = MyEditText(initialValue: "Default Timer");
    var durationEditText = MyEditText(
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
                      _addTimer(nameEditText.state.initialValue,
                          int.parse(durationEditText.state.initialValue));
                      Navigator.of(context).pop();
                    },
                    child: Text("Start")),
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel")),
              ],
            ),
        barrierDismissible: false);
  }

  void _addTimer(String title, int duration) {
    setState(() {
      listTimer.add(MyTimer(
          myHomePageState: this,
          title: title,
          timer: Duration(minutes: duration)));
    });
  }

  void deleteTimer(MyTimer timer) {
    setState(() {
      print("deleting ${timer.title}");
      listTimer.remove(timer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          child: ListView.builder(
        shrinkWrap: true,
        itemCount: listTimer.length,
        itemBuilder: (BuildContext context, int i) {
          return listTimer[i];
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setUpDialog(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MyTimer extends StatefulWidget {
  String title;
  Duration timer;
  _MyHomePageState myHomePageState;

  MyTimer({Key key, this.myHomePageState, this.title, this.timer})
      : super(key: key);

  @override
  _MyTimerState createState() => _MyTimerState();
}

class _MyTimerState extends State<MyTimer> {
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
  }

  void startTimer() {
    if (listenToSeconds == null) {
      start = DateTime.now();
      var lastTime = DateTime.now();
      listenToSeconds = Second().second.stream.listen((second) {
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
    print("delete ${widget.title}");
    endTimer();
    listenToSeconds.cancel();
    widget.myHomePageState.deleteTimer(widget);
  }

  void play() {
    print("play");
    startTimer();
    sound = Sound();
    sound.init();
    soundId = sound.loadSound();
    ongoing = true;
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
        milliseconds: widget.timer.inMilliseconds -
            (getElapsedTime().inMilliseconds - getPausedTime().inMilliseconds));
  }

  String getTimeString(Duration duration) {
    if (duration.isNegative) return "00";
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes =
    twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds =
    twoDigits(duration.inSeconds.remainder(60));
    if(duration.inMinutes >= 60) {
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
    var totalTime = widget.timer.inMilliseconds;
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
          color: ended ? MyColors().blackChocolate : MyColors().royalBlue,
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
                          AlwaysStoppedAnimation<Color>(MyColors().cerise),
                    )),
                Expanded(
                    child: Text(
                  getTimeString(getRemainingTime()),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: MyColors().snow),
                )),
              ],
            ),
            Expanded(
                flex: 5,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: MyColors().snow),
                      ),
                      Text(
                        getTimeString(widget.timer),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: MyColors().snow),
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
                      color: MyColors().snow,
                    ))),
            Expanded(
                flex: 2,
                child: FlatButton(
                    onPressed: () => delete(),
                    child: Icon(
                      Icons.delete_forever,
                      color: MyColors().snow,
                    ))),
          ],
        ));
  }
}

class Sound {
  Soundpool soundPool;

  void init() {
    instantiate();
  }

  Future<void> instantiate() async {
    WidgetsFlutterBinding.ensureInitialized();
    soundPool = Soundpool();
  }

  Future<int> loadSound() async {
    var asset = await rootBundle.load("assets/sounds/widefngr.wav");
    return await soundPool.load(asset);
  }

  Future<void> playSound(Future<int> soundId) async {
    var _sound = await soundId;
    await soundPool.play(_sound);
  }
}

class Second {
  StreamController<void> second = StreamController();

  Second() {
    Timer.periodic(Duration(milliseconds: 1000), (t) {
      second.add("");
    });
  }
}

class MyEditText extends StatefulWidget {
  final String initialValue;
  final int maxLength;
  final TextInputType inputType;

  MyEditText({Key key, this.initialValue, this.maxLength, this.inputType})
      : super(key: key);

  _MyEditTextState state;

  @override
  _MyEditTextState createState() => state = _MyEditTextState();
}

class _MyEditTextState extends State<MyEditText> {
  String initialValue;
  var _isEditingText = true;
  var _editingController;

  @override
  void initState() {
    initialValue = widget.initialValue;
    _editingController = TextEditingController(text: initialValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isEditingText
        ? TextField(
            maxLines: 1,
            maxLength: widget.maxLength ?? 25,
            keyboardType: widget.inputType ?? TextInputType.text,
            onTap: () {
              setState(() {
                if (_isEditingText == false) {
                  initialValue = "";
                  _isEditingText = true;
                }
              });
            },
            onChanged: (newValue) {
              setState(() {
                print(newValue);
                initialValue = newValue;
              });
            },
            onSubmitted: (newValue) {
              setState(() {
                initialValue = newValue;
                _isEditingText = false;
              });
            },
            autofocus: true,
            controller: _editingController)
        : InkWell(
            onTap: () {
              setState(() {
                _isEditingText = true;
              });
            },
            child: Text(initialValue,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                )));
  }
}
