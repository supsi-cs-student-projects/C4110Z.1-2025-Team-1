import 'package:demo_todo_with_flutter/routes/LoginPage.dart';
import 'package:demo_todo_with_flutter/routes/RegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(MaterialApp.router(
    routerConfig: _router, // Use GoRouter
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        primary: Colors.black,
      ),
      fontFamily: 'Avenir',
    ),
  ));
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/', // Default route (LoginPage)
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: '/RegisterPage.dart', // Route for RegisterPage
      builder: (context, state) => const RegisterPage(),
    ),

    GoRoute(
      path: '/LoginPage.dart', // Route for LoginPage
      builder: (context, state) => const LoginPage(),
    ),
  ],
);



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
