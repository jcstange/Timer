import 'package:hive/hive.dart';
import '../Entities.dart';

class Storage {
  void storeUser(User user) {
    var box = Hive.box('TimesUpUser');
    box.put('user', user);
  }

  User getUser() {
    var box = Hive.box('TimesUpUser');
    box.get('user');
  }

  void removeUser() {

  }
}