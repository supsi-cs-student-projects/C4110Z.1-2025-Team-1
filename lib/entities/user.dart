import '../services/GameService.dart';
import '../services/MilestoneManager.dart';
import '../services/Streak.dart';
import '../services/auth.dart';

class User {
  final String nickname;
  int higherLowerBestScore;
  int streakCount;
  int xp;

  final GameService _gameService = GameService();
  final StreakService _streakService = StreakService();
  final AuthService _authService = AuthService();
  final milestoneManager = MilestoneManager(gameService: GameService());

  User({
    required this.nickname,
    required this.higherLowerBestScore,
    required this.streakCount,
    required this.xp,
  });

  /// Fetch the user's stats from Appwrite
  static Future<User> fetchUser() async {
    try {
      final account = await AuthService().getAccount();
      final nickname = account.name;

      final gameService = GameService();
      final higherLowerBestScore = await gameService.getBestScore();
      final xp = await gameService.getXP();

      final streakCount = await StreakService().getStreakCount();

      return User(
        nickname: nickname,
        higherLowerBestScore: higherLowerBestScore,
        streakCount: streakCount,
        xp: xp,
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

  /// Increment the user's daily streak (only once per day)
  Future<void> incrementStreak() async {
    final streak = await _streakService.loadStreak();
    final nowUtc = DateTime.now().toUtc();
    final lastUpdatedUtc = streak.lastUpdated.toUtc();

    // Calculate next local midnight then convert to UTC
    final nowLocal = DateTime.now();
    final todayMidnightLocal = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    final nextMidnightLocal = todayMidnightLocal.add(Duration(days: 1));
    final nextAllowedUtc = nextMidnightLocal.toUtc();

    // If still before next local day, deny increment
    if (nowUtc.isBefore(nextAllowedUtc) && _isSameDay(nowUtc, lastUpdatedUtc)) {
      final remaining = nextAllowedUtc.difference(nowUtc);
      print('Streak can only be incremented once per calendar day.');
      print(
          'Time remaining until next day: '
              '${remaining.inHours}h '
              '${remaining.inMinutes % 60}m '
              '${remaining.inSeconds % 60}s'
      );
      return;
    }

    // If more than a day has passed since last update, reset streak
    final daysSinceLast = nowUtc.difference(lastUpdatedUtc).inDays;
    if (daysSinceLast > 1) {
      await _streakService.resetStreak();
      streakCount = 1;
      return;
    }

    // Otherwise, normal increment
    final updatedStreak = await _streakService.incrementStreak();
    streakCount = updatedStreak.streakCount;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Increment XP by a given amount
  Future<void> addXP(int amount) async {
    xp += amount;
    milestoneManager.checkMilestones(xp);
    await _gameService.updateXP(xp);
  }

  /// Get current XP
  int getXP() {
    return xp;
  }
}
