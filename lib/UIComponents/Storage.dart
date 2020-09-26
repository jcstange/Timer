import 'package:hive/hive.dart';

Future<void> storeUser(String userEmail) async {
  var box = await Hive.openBox('TimesUpUser');
  box.put('user', userEmail);
}

Future<String> getStorageUser() async {
  var box = await Hive.openBox('TimesUpUser');
  return box.get('user');
}

Future<void> removeStorageUser(String userEmail) async {
  var box = await Hive.openBox('TimesUpUser');
  box.delete('user');
}
