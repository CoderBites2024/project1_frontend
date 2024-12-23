import 'package:flutter/material.dart';
import 'package:p_project1/dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard()
      // home: AddUser()
    );
  }
}

