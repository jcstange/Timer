import 'dart:convert';

import 'package:Timer/Entities.dart';
import 'package:http/http.dart' as http;

Future<List<User>> getUsers() async {
  final response = await http.get(
      'https://70m2ndirwd.execute-api.eu-north-1.amazonaws.com/test/user/');
  if (response.statusCode == 200) {
    List<User> users = [];
    var responseBody = json.decode(response.body)['body'];
    print('responseBody = $responseBody');
    for (dynamic i in responseBody) {
      print('i = $i');
      User.fromJson(i);
    }
    return users;
  } else {
    throw Exception("Failed to fetch users");
  }
}

Future<User> getUser(String user) async {
  final response = await http.get(
      'https://70m2ndirwd.execute-api.eu-north-1.amazonaws.com/test/user/$user');
  if (response.statusCode == 200) {
    var responseBody = json.decode(response.body)['body'];
    return User.fromJson(responseBody);
  } else {
    throw Exception("Failed to fetch user");
  }
}

Future<User> addUser(String user) async {
  var newUser = User(
      username: user.substring(0,user.indexOf('@')),
      email: user,
      items: []
  );
  print('newUser = $newUser');
  final response = await http.post(
      'https://70m2ndirwd.execute-api.eu-north-1.amazonaws.com/test/user/',
      headers:<String, String> {
        'Content-Type': 'application/json'
      },
      body: json.encode(newUser)
  );
  if (response.statusCode == 200) {
    var responseBody = json.decode(response.body)['body'];
    return User.fromJson(responseBody);
  } else {
    throw Exception("Failed to fetch user");
  }
}

Future<User> deleteUser(String user) async {
  final response = await http.delete(
      'https://70m2ndirwd.execute-api.eu-north-1.amazonaws.com/test/user/$user');
  if (response.statusCode == 200) {
    var responseBody = json.decode(response.body)['body'];
    return User.fromJson(responseBody);
  } else {
    throw Exception("Failed to delete user");
  }
}

Future<void> addItem(String user, Item item) async {
  print(json.encode(item.toJson()));

  final response = await http.post(
    'https://70m2ndirwd.execute-api.eu-north-1.amazonaws.com/test/user/$user',
    headers:<String, String> {
      'Content-Type': 'application/json'
    },
    body: json.encode(item.toJson()),
  );
  if (response.statusCode == 200) {
    var responseBody = json.decode(response.body)['body'];
    print(responseBody);
    //return User.fromJson(responseBody);
  } else {
    throw Exception("Failed to add item");
  }
}

Future<User> updateItem(String user, Item item) async {
  final response = await http.post(
    'https://70m2ndirwd.execute-api.eu-north-1.amazonaws.com/test/user/$user',
    headers: <String, String>{
      'Content-Type': 'application/json'
    },
    body: json.encode(item.toJson()),
  );
  if (response.statusCode == 200) {
    var responseBody = json.decode(response.body)['body'];
    return User.fromJson(responseBody);
  } else {
    throw Exception("Failed to update item");
  }
}

Future<User> removeItem(String user, Item item) async {
  var request = http.Request(
      "DELETE",
      Uri.parse('https://70m2ndirwd.execute-api.eu-north-1.amazonaws.com/test/user/$user')
  );
  request.headers.addAll(<String, String>{
    'Content-Type': 'application/json'
  });
  request.body = json.encode(item.toJson());
  final response = await request.send();
  if (response.statusCode == 200) {
    var responseBody = json.decode(await response.stream.bytesToString())['body'];
    return User.fromJson(responseBody);
  } else {
    throw Exception("Failed to remove item");
  }
}
