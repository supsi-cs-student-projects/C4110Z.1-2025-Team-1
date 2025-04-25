import '../services/GameService.dart';
import '../services/streak.dart';
import '../services/auth.dart';

class User {
  final String nickname;
  int higherLowerBestScore;
  int streakCount;

  final GameService _gameService = GameService();
  final StreakService _streakService = StreakService();
  final AuthService _authService = AuthService();

  User({
    required this.nickname,
    required this.higherLowerBestScore,
    required this.streakCount,
  });

  /// Fetch the user's stats from Appwrite
  static Future<User> fetchUser() async {
    try {
      // Fetch the user's account
      final account = await AuthService().getAccount();
      final nickname = account.name;

      // Fetch the user's higher-lower best score
      final higherLowerBestScore = await GameService().getBestScore();

      // Fetch the user's streak count
      final streakCount = await StreakService().getStreakCount();

      return User(
        nickname: nickname,
        higherLowerBestScore: higherLowerBestScore,
        streakCount: streakCount,
      );
    } catch (e) {
      throw Exception('Failed to fetch user stats: $e');
    }
  }

  /// Update the user's higher-lower best score
  Future<void> updateHigherLowerBestScore(int newBestScore) async {
    if (newBestScore > higherLowerBestScore) {
      higherLowerBestScore = newBestScore;
      await _gameService.updateBestScore(newBestScore);
    }
  }

  /// Increment the user's streak count
  Future<void> incrementStreak() async {
    streakCount++;
    await _streakService.incrementStreak();
  }
}