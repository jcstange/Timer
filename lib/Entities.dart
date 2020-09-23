import 'dart:convert';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String email;

  @HiveField(3)
  List<Item> items;

  User({this.username, this.email, this.items});

  factory User.fromJson(Map<String, dynamic> jsonObject) {
    print(jsonObject);
    var user = User(
      username: jsonObject['username'],
      email: jsonObject['email'],
      items: jsonObject['items'].map<Item>((i) {
        return Item.fromJson(i);
      }).toList(),
    );
    print(user.toJson());
    return user;
  }

  Map<String, dynamic> toJson() => {
    "username": username,
    "email": email,
    "items": items
  };
}

@HiveType(typeId: 1)
class Item {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int sessionDuration;

  @HiveField(3)
  int sessions;

  @HiveField(4)
  int restDuration;

  @HiveField(5)
  int startTime;

  @HiveField(6)
  int endTime;

  Item({
    this.id,
    this.name,
    this.sessionDuration,
    this.sessions,
    this.restDuration,
    this.startTime,
    this.endTime,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    var item = Item(
      id: json['id'],
      name: json['name'],
      sessionDuration: json['session_duration'],
      sessions: json['sessions'],
      restDuration: json['rest_duration'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
    print(item.toJson());
    return item;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "session_duration": sessionDuration,
    "sessions": sessions,
    "rest_duration": restDuration,
    "start_time": startTime,
    "end_time": endTime
  };
}
