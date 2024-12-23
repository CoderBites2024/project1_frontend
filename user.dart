import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://localhost:3000/api/users';

List<Map<String, dynamic>> users = [];

class User {
  final int? id;
  final String name;
  final String email;
  final int sentEmails;
  final String activitiTime;
  final String activityState;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.sentEmails,
    required this.activitiTime,
    required this.activityState,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      sentEmails: json['sent_emails'],
      activitiTime: json['activiti_time'],
      activityState: json['activity_state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'sent_emails': sentEmails,
      'activity_state': activityState,
    };
  }
}

// Fetch all users
Future<List<Map<String, dynamic>>> fetchUsers() async {
  final response = await http.get(Uri.parse(baseUrl));
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
     List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonResponse);
    return data;
    // return data.map((user) => User.fromJson(user)).toList();
  } else {
    throw Exception('Failed to load users');
  }

}

// Fetch user by ID
Future<User> fetchUserById(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/$id'));

  if (response.statusCode == 200) {
    return User.fromJson(json.decode(response.body));
  } else {
    throw Exception('User not found');
  }
}

// Create a new user
Future<User> createUser(User user) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(user.toJson()),
  );

  if (response.statusCode == 201) {
    return User.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create user');
  }
}

// Update an existing user
Future<User> putUser(int id, User user) async {
  final response = await http.put(
    Uri.parse('$baseUrl/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(user.toJson()),
  );

  if (response.statusCode == 200) {
    return User.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to update user');
  }
}

// Delete a user
Future<void> deleteUser(int id) async {
  final response = await http.delete(Uri.parse('$baseUrl/$id'));

  if (response.statusCode != 204) {
    throw Exception('Failed to delete user');
  }
}
