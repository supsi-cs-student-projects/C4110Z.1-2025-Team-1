import 'package:appwrite/models.dart' as models;
import 'package:demo_todo_with_flutter/services/GameService.dart';
import 'package:demo_todo_with_flutter/services/streak.dart';
import 'package:flutter/material.dart';

import '../services/auth.dart'; // Importa il servizio AuthService

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<models.Account> _accountFuture;
  final authService = AuthService(); // Istanza del servizio AuthService
  final gameService = GameService(); // Istanza del servizio GameService
  final streakService = StreakService(); // Istanza del servizio StreakService

  @override
  void initState() {
    super.initState();
    _accountFuture = authService.getAccount(); // Carica i dati iniziali
  }

  void _reloadData() {
    setState(() {
      _accountFuture = authService.getAccount(); // Ricarica i dati
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context,
                true); // Passa `true` per indicare che i dati sono stati aggiornati
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
        future: _accountFuture, // Usa il Future aggiornabile
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
                    const SizedBox(height: 10),
                    Table(
                      border: TableBorder.all(color: Colors.black),
                      children: [
                        const TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Statistic',
                                style: TextStyle(
                                  fontFamily: 'RetroGaming',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Value',
                                style: TextStyle(
                                  fontFamily: 'RetroGaming',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('XP'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FutureBuilder<int>(
                                future: gameService.getXP(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error');
                                  } else {
                                    return Text('${snapshot.data ?? 0}');
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Streak'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FutureBuilder<int>(
                                future: streakService.getStreakCount(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error');
                                  } else {
                                    return Text('${snapshot.data ?? 0} days');
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Best Score'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FutureBuilder<int>(
                                future: gameService.getBestScore(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error');
                                  } else {
                                    return Text('${snapshot.data ?? 0}');
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // Resetta le statistiche e la streak
                          await gameService.resetStats();
                          await streakService.resetStreak();

                          // Ricarica i dati
                          _reloadData();

                          // Mostra un messaggio di successo
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Stats and streak reset successfully!')),
                          );
                        } catch (e) {
                          // Mostra un messaggio di errore
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Failed to reset stats or streak: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF18a663), // Colore del pulsante
                      ),
                      child: const Text(
                        'Reset Stats and Streak',
                        style: TextStyle(
                          fontFamily: 'RetroGaming',
                          fontWeight: FontWeight.bold,
                        ),
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
