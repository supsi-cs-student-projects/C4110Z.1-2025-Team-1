import 'package:demo_todo_with_flutter/services/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../services/Streak.dart';
import '../services/auth.dart';
import '../utilities.dart';
import 'todos.dart';

class AuthService {
  final Account _account = Account(Appwrite.instance.client);

  // Metodo per registrare un nuovo utente
  Future<models.Account> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      return login(
          email: email,
          password: password); // Effettua il login dopo la registrazione
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Metodo per effettuare il login
  Future<models.Account> login({
    required String email,
    required String password,
  }) async {
    try {
      await _account.createEmailSession(
        email: email,
        password: password,
      );
      return _account.get(); // Restituisce i dettagli dell'account
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Metodo per ottenere i dettagli dell'account corrente
  Future<models.Account> getAccount() async {
    try {
      return await _account.get();
    } catch (e) {
      throw Exception('Failed to fetch account: $e');
    }
  }

  // Metodo per effettuare il logout
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  // Metodo per aggiornare lo username
  Future<void> updateUsername(String newUsername, String password) async {
    try {
      await _account.updateName(
          name: newUsername); // Metodo Appwrite per aggiornare il nome
      _account.updateEmail(
          email: "$newUsername@bloom.com",
          password: password); // Metodo Appwrite per aggiornare l'email
    } catch (e) {
      throw Exception('Failed to update username: $e');
    }
  }
}

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final authService = AuthService();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final streak = StreakService();
  bool isSignUp = false;

  void toggleSignUp() {
    setState(() {
      isSignUp = !isSignUp;
    });
  }

  void submit() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (isSignUp) {
        await authService.signUp(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
        );
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        setState(() {
          isSignUp = false;
        });
      } else {
        await authService.login(
          email: emailController.text,
          password: passwordController.text,
        );
        emailController.clear();
        passwordController.clear();
      }
      navigator.push(
        MaterialPageRoute(builder: (context) => const Todos()),
      );
    } catch (e) {
      messenger.showSnackBar(createErrorSnackBar(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final headlineStyle = Theme.of(context).textTheme.displayMedium?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w900,
        );

    const spacing = 10.0;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSignUp ? "Sign Up" : "Login",
              style: headlineStyle,
            ),
            const SizedBox(height: spacing),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: isSignUp
                        ? "Already have an account ? "
                        : "Don't have an account ? ",
                    style: const TextStyle(color: Colors.black),
                  ),
                  WidgetSpan(
                    child: InkWell(
                      onTap: toggleSignUp,
                      child: Text(
                        isSignUp ? 'Login' : 'Sign Up',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSignUp) const SizedBox(height: spacing),
            if (isSignUp)
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
            const SizedBox(height: spacing),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            const SizedBox(height: spacing),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.send,
              decoration: const InputDecoration(
                labelText: "Password",
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              onFieldSubmitted: (value) {
                submit();
              },
            ),
            const SizedBox(height: spacing),
            ElevatedButton(
              onPressed: submit,
              child: Text(
                isSignUp ? "Sign Up" : "Login",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
