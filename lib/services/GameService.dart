import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../services/appwrite.dart';
import '../services/auth.dart';

class GameService {
  final Databases _databases = Databases(Appwrite.instance.client);
  final String _databaseId = 'default'; // Replace with your Appwrite database ID
  final String _collectionId = '6809339a0024c90db465'; // Replace with your Appwrite collection ID
  String? _userId;

  Future<int> getBestScore() async {
    try {
      // Fetch the user's account
      models.Account account = await AuthService().getAccount();
      _userId = account.$id;

      // Fetch the user's document
      final document = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _userId!,
      );

      return document.data['higherLower'] ?? 0; // Return 0 if bestScore is null
    } catch (e) {
      if (e is AppwriteException && e.code == 404) {
        // If the document doesn't exist, initialize it
        await _initializeUserDocument();
        return 0;
      } else {
        throw Exception('Failed to fetch best score: $e');
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

  Future<void> _initializeUserDocument() async {
    await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: _userId!,
      data: {
        'higherLower': 0,
      },
    );
  }
}