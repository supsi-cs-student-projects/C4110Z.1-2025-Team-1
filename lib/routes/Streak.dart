import 'package:flutter/material.dart';
import 'package:demo_todo_with_flutter/services/auth.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../services/appwrite.dart';

class Streak extends StatefulWidget {
  const Streak({super.key});

  @override
  State<Streak> createState() => _StreakPageState();
}

class _StreakPageState extends State<Streak> {
  final AuthService _authService = AuthService();
  final Databases _databases = Databases(Appwrite.instance.client);
  final String _databaseId =
      'default'; // Replace with your Appwrite database ID
  final String _collectionId =
      '67db391b00064570c8a1'; // Replace with your Appwrite collection ID
  String? _userId;
  int _streakCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    try {
      // Get the current user's account
      models.Account account = await _authService.getAccount();
      _userId = account.$id;

      // Fetch the user's streak from the database
      final document = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _userId!,
      );

      setState(() {
        _streakCount = document.data['streak'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      // If the document doesn't exist, initialize it
      if (e is AppwriteException && e.code == 404) {
        await _initializeStreak();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading streak: $e')),
        );
      }
    }
  }

  Future<void> _initializeStreak() async {
    try {
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _userId!,
        data: {'streak': 0},
      );

      setState(() {
        _streakCount = 0;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing streak: $e')),
      );
    }
  }

  Future<void> _incrementStreak() async {
    try {
      setState(() {
        _streakCount++;
      });

      // Update the streak in the database
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _userId!,
        data: {'streak': _streakCount},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating streak: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak Page'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your Current Streak:',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  '$_streakCount Days',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _incrementStreak,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Increase Streak',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }
}
