class Streak {
    int streakCount;
    DateTime lastUpdated;

    Streak({
        required this.streakCount,
        required this.lastUpdated,
    });

    factory Streak.fromJson(Map<String, dynamic> json) {
        return Streak(
            streakCount: json['streak'] ?? 0,
            lastUpdated: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
        );
    }

    void increment() {
      streakCount++;
      lastUpdated = DateTime.now();
        // if (DateTime.now().day != lastUpdated.day) {
        //     streakCount++;
        //     lastUpdated = DateTime.now();
        // }
    }

    Map<String, dynamic> toJson() {
        return {
            'streak': streakCount,
            'updated_at': lastUpdated.toIso8601String(),
        };
    }
}