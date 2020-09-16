import 'dart:convert';

class User {
  String username;
  String email;
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

class Item {
  int id;
  String name;
  int sessionDuration;
  int sessions;
  int restDuration;
  int startTime;
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
