import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:demo_todo_with_flutter/entities/user.dart';
import 'package:flutter/material.dart';

import '../services/appwrite.dart';
import '../services/streak.dart';

class AuthService {
  final Account _account = Account(Appwrite.instance.client);
  final StreakService _streakService = StreakService();

  Future<models.Account> signUp(
      {String? name, required String email, required String password}) async {
    await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    return login(email: email, password: password);
  }

  Future<models.Account> login(
      {required String email, required String password}) async {
    await _account.createEmailSession(
      email: email,
      password: password,
    );
    return _account.get();
  }

  Future<models.Account> getAccount() async {
    return _account.get();
  }

  Future<void> logout() {
    return _account.deleteSession(sessionId: 'current');
  }

  Future<String> getName() {
    return _account.get().then((value) => value.name);
  }

  // Metodo per aggiornare lo username
  Future<void> updateUsername(String newUsername, String password) async {
    try {
      await _account.updateName(name: newUsername);
      await _account.updateEmail(
        email: "$newUsername@bloom.com",
        password: password,
      );
    } on AppwriteException catch (e) {
      if (e.code == 409) {
        throw Exception('Username already exists.');
      } else if (e.code == 401) {
        throw Exception('Incorrect password.');
      } else {
        throw Exception(e.message ?? 'An unknown error occurred.');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }


  void _showChangeUsernameDialog(BuildContext context, User user) {
    final TextEditingController usernameController =
    TextEditingController(text: user.nickname);
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Username'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'New Username',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Chiudi il dialog senza salvare
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newUsername = usernameController.text.trim();
                final password = passwordController.text.trim();

                if (newUsername.isNotEmpty && password.isNotEmpty) {
                  try {
                    final authService = AuthService();
                    await authService.updateUsername(newUsername, password);

                    // Mostra un messaggio di successo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Username updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context); // Chiudi il dialog
                  } catch (e) {
                    // Mostra un messaggio di errore
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update username: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  // Mostra un messaggio di errore se i campi sono vuoti
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Username and password cannot be empty!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}