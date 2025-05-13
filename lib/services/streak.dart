import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../entities/Streak.dart';
import '../services/auth.dart';
import 'appwrite.dart';

class StreakService {
  final Databases _databases = Databases(Appwrite.instance.client);
  final String _databaseId = 'default';
  final String _collectionId = '67db391b00064570c8a1';
  String? _userId;

  /// Ensure _userId is set by fetching current account
  Future<void> _ensureUserId() async {
    if (_userId == null) {
      final account = await AuthService().getAccount();
      _userId = account.$id;
    }
  }

  Future<Streak> loadStreak() async {
    await _ensureUserId();
    try {
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
        throw Exception('Failed to load streak: \$e');
      }
    }
  }

  Future<int> getStreakCount() async {
    final streak = await loadStreak();
    return streak.streakCount;
  }

  Future<Streak> initializeStreak() async {
    await _ensureUserId();
    //yesterday's date
    final yesterday = DateTime.now().subtract(Duration(days: 1)).toUtc();
    final document = await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: _userId!,
      data: {
        'streak': 0,
        'updated_at': yesterday.toIso8601String(),
      },
    );
    return Streak.fromJson(document.data);
  }

  /// Reset streak and roll back timer so user can increment immediately
  Future<Streak> resetStreak() async {
    await _ensureUserId();
    final nowUtc = DateTime.now().toUtc();
    // Subtract one day so next increment is allowed right away
    final resetTimestamp = nowUtc.subtract(Duration(days: 1));
    final document = await _databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: _userId!,
      data: {
        'streak': 0,
        'updated_at': resetTimestamp.toIso8601String(),
      },
    );
    return Streak.fromJson(document.data);
  }

  Future<Streak> incrementStreak() async {
    // Load the current streak
    final streak = await loadStreak();

    // Get the current UTC date and the last updated date
    final nowUtc = DateTime.now().toUtc();
    final lastUpdatedDate = DateTime(
      streak.lastUpdated.year,
      streak.lastUpdated.month,
      streak.lastUpdated.day,
    );
    final currentDate = DateTime(nowUtc.year, nowUtc.month, nowUtc.day);

    // Check if the streak was already incremented today
    if (lastUpdatedDate == currentDate) {
      throw Exception('Streak already incremented today.');
    }

    // If the streak is fresh (e.g., streakCount is 0), initialize it
    // Increment the streak
    streak.increment();

    // Update the streak in the database
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
