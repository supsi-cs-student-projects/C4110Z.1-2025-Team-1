import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:demo_todo_with_flutter/services/auth.dart'; // Importa il servizio AuthService

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(); // Istanza del servizio AuthService

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Torna alla homepage
          },
        ),
        title: const Text(
          'Account',
          style: TextStyle(
            fontFamily: 'RetroGaming',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF18a663),
      ),
      body: FutureBuilder(
        future: authService.getAccount(), // Recupera i dati dell'account
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Mostra un indicatore di caricamento
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(
                  fontFamily: 'RetroGaming',
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final account = snapshot.data as models.Account;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RetroGaming',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Username: ${account.name ?? "No name provided"}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'RetroGaming',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${account.email}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'RetroGaming',
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: Text(
                'No account information available.',
                style: TextStyle(
                  fontFamily: 'RetroGaming',
                  fontSize: 18,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
