import 'package:demo_todo_with_flutter/routes/LoginPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ToDoApp());
    
}


class ToDoApp extends StatelessWidget {
  const ToDoApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo with Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
        ),
        fontFamily: 'Avenir',
      ),
      home: const LoginPage(),
    );
  }
}
