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

  String get getNickname => nickname;
  int get getHigherLowerBestScore => higherLowerBestScore;
  int get getStreakCount => streakCount;

  static Future<User> fetchUser() async {
    try {
      final account = await AuthService().getAccount();
      final nickname = account.name;

      final higherLowerBestScore = await GameService().getBestScore();

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

  static Future<User> resolveUser(Future<User> futureUser) async {
    return await futureUser;
  }

  Future<void> updateHigherLowerBestScore(int newBestScore) async {
    if (newBestScore > higherLowerBestScore) {
      higherLowerBestScore = newBestScore;
      await _gameService.updateBestScore(newBestScore);
    }
  }

  Future<void> incrementStreak() async {
    streakCount++;
    await _streakService.incrementStreak();
  }
}