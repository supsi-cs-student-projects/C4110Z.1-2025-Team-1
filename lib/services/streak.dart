import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../entities/streak.dart';
import '../services/appwrite.dart';
import '../services/auth.dart';

class StreakService {
  final Databases _databases = Databases(Appwrite.instance.client);
  final String _databaseId =
      'default'; // Replace with your Appwrite database ID
  final String _collectionId =
      '67c5e29a0030f33704a7'; // Replace with your Appwrite collection ID
  String? _userId;

  Future<Streak> loadStreak() async {
    try {
      // Fetch the user's account
      models.Account account = await AuthService().getAccount();
      _userId = account.$id;

      // Fetch the streak document
      final document = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _userId!,
      );

      return Streak.fromJson(document.data);
    } catch (e) {
      if (e is AppwriteException && e.code == 404) {
        return await initializeStreak();
      } else {
        throw Exception('Failed to load streak: $e');
      }
    }
  }

  Future<int> getStreakCount() async {
    final streak = await loadStreak();
    return streak.streakCount;
  }

  Future<Streak> initializeStreak() async {
    final document = await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: _userId!,
      data: {
        'streak': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );

    return Streak.fromJson(document.data);
  }

  Future<Streak> incrementStreak() async {
    final streak = await loadStreak();
    final now = DateTime.now();

    // Check if the streak can be incremented (only once per day)
     if (now.difference(streak.lastUpdated).inDays < 1) {
       throw Exception('Streak can only be incremented once per day.');
    }

    streak.increment();

    final document = await _databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: _userId!,
      data: {
        'streak': streak.streakCount,
        'updated_at': streak.lastUpdated.toIso8601String(),
      },
    );
    return Streak.fromJson(document.data);
  }
}
