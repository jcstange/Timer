import 'dart:async';

class Tick {
  StreamController<void> second = StreamController();

  Tick() {
    Timer.periodic(Duration(milliseconds: 1000), (t) {
      second.add("");
    });
  }
}
