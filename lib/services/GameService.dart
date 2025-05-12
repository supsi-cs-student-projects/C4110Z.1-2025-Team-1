import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../services/appwrite.dart';
import '../services/auth.dart';

class GameService {
  final Databases _databases = Databases(Appwrite.instance.client);
  final String _databaseId = 'default';
  final String _collectionId = '6809339a0024c90db465';
  String? _userId;

  Future<int> getBestScore() async {
    try {
      models.Account account = await AuthService().getAccount();
      _userId = account.$id;

      final document = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _userId!,
      );

      return document.data['higherLower'] ?? 0;
    } catch (e) {
      if (e is AppwriteException && e.code == 404) {
        await _initializeUserDocument();
        return 0;
      } else {
        throw Exception('Failed to fetch best score: $e');
      }
    }
  }

  Future<int> getXP() async {
    try {
      models.Account account = await AuthService().getAccount();
      _userId = account.$id;

      final document = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _userId!,
      );

      return document.data['xp'] ?? 0;
    } catch (e) {
      if (e is AppwriteException && e.code == 404) {
        await _initializeUserDocument();
        return 0;
      } else {
        throw Exception('Failed to fetch XP: $e');
      }
    }
  }

  Future<void> updateBestScore(int newBestScore) async {
    try {
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _userId!,
        data: {
          'higherLower': newBestScore,
        },
      );
    } catch (e) {
      throw Exception('Failed to update best score: $e');
    }
  }

  Future<void> updateXP(int newXP) async {
    try {
      models.Account account = await AuthService().getAccount();
      _userId = account.$id;

      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _userId!,
        data: {
          'xp': newXP,
        },
      );
    } catch (e) {
      throw Exception('Failed to update XP: $e');
    }
  }

  Future<void> updateMilestones(int milestone) async {
    try {
      // Get the current user ID
      models.Account account = await AuthService().getAccount();
      _userId = account.$id;

      // Fetch current document
      final doc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _userId!,
      );

      // Get current milestones array
      List<dynamic> currentMilestones = doc.data['milestones'] ?? [];

      // Avoid duplicates (optional)
      if (!currentMilestones.contains(milestone)) {
        currentMilestones.add(milestone);
      }

      // Update the document with the new array
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _userId!,
        data: {
          'milestones': currentMilestones,
        },
      );
    } catch (e) {
      throw Exception('Failed to update milestones: $e');
    }
  }

  Future<void> resetStats() async {
    try {
      // Recupera l'account dell'utente per ottenere l'ID
      models.Account account = await AuthService().getAccount();
      _userId = account.$id;

      // Aggiorna il documento dell'utente con i valori resettati
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _userId!,
        data: {
          'xp': 0,
          'higherLower': 0,
        },
      );
    } catch (e) {
      throw Exception('Failed to reset stats: $e');
    }
  }

  Future<void> _initializeUserDocument() async {
    await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: _userId!,
      data: {
        'higherLower': 0,
        'xp': 0,
        'milestones': [],
      },
    );
  }
}
