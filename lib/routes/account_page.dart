import 'package:flutter/material.dart';
import '../entities/user.dart';
import '../services/auth.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<User> _futureUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    _futureUser = User.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, false);
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
      body: FutureBuilder<User>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
            final user = snapshot.data!;
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
                      'Username: ${user.nickname}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'RetroGaming',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _showChangeUsernameDialog(context, user);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF18a663),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        'Change Username',
                        style: TextStyle(
                          fontFamily: 'RetroGaming',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RetroGaming',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IntrinsicWidth(
                        child: Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFEFEF),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(
                                        'Statistic',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'RetroGaming',
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(
                                        'Value',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'RetroGaming',
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildTableRow('XP', '${user.xp}'),
                            _buildTableRow('Streak', '${user.streakCount} days'),
                            _buildTableRow('Best Score', '${user.higherLowerBestScore}'),
                          ],
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

  Widget _buildTableRow(String label, String value) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'RetroGaming',
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'RetroGaming',
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                Navigator.pop(context); // Chiudi il dialog
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

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Username updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context); // Chiudi il dialog

                    setState(() {
                      _loadUser(); // Ricarica i dati utente
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update username: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                      Text('Username and password cannot be empty!'),
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
