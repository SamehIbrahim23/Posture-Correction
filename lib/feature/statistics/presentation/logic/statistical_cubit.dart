// Posture analysis data class
import 'package:camera_stream/constants.dart';
import 'package:camera_stream/feature/statistics/presentation/logic/statistical_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

import '../../data/models/statistics_model.dart';

class PostureAnalysis {
  final int goodPostureCount;
  final int neutralPostureCount;
  final int poorPostureCount;
  final double goodPosturePercentage;
  final double neutralPosturePercentage;
  final double poorPosturePercentage;
  final List<DailyPostureData> dailyData;
  final List<HourlyPostureData> hourlyData;
  final double averageScore;
  final String trend;
  final double trendPercentage;
  final Duration totalGoodPostureTime;
  final Duration averageSessionTime;

  PostureAnalysis({
    required this.goodPostureCount,
    required this.neutralPostureCount,
    required this.poorPostureCount,
    required this.goodPosturePercentage,
    required this.neutralPosturePercentage,
    required this.poorPosturePercentage,
    required this.dailyData,
    required this.hourlyData,
    required this.averageScore,
    required this.trend,
    required this.trendPercentage,
    required this.totalGoodPostureTime,
    required this.averageSessionTime,
  });
}

class DailyPostureData {
  final DateTime date;
  final double score;
  final int goodCount;
  final int poorCount;

  DailyPostureData({
    required this.date,
    required this.score,
    required this.goodCount,
    required this.poorCount,
  });
}

class HourlyPostureData {
  final int hour;
  final double score;
  final int count;

  HourlyPostureData({
    required this.hour,
    required this.score,
    required this.count,
  });
}

// Enhanced Cubit
class StatisticsCubit extends Cubit<StatisticsState> {
  final Box<StatisticsModel> _box = Hive.box<StatisticsModel>(kStatisticsBox);
  String selectedTimeframe = 'Week';

  StatisticsCubit() : super(StatisticsInitial());
  void changeTimeframe(String timeframe) {
    selectedTimeframe = timeframe;
    fetchStatistics();
  }

  Future<void> addStatistics(String msg) async {
    try {
      final newStats = StatisticsModel(
        msg: msg,
        time: DateTime.now(),
      );

      await _box.add(newStats);
      await fetchStatistics();
    } catch (e) {
      emit(StatisticsError('Failed to add statistics: $e'));
    }
  }

  Future<void> fetchStatistics() async {
    try {
      final statisticsList = _box.values.toList();
      final filteredStats = _filterByTimeframe(statisticsList);
      final analysis = _analyzePostureData(filteredStats);

      emit(StatisticsLoaded(filteredStats, analysis));
    } catch (e) {
      emit(StatisticsError('Failed to fetch statistics: $e'));
    }
  }

  List<StatisticsModel> _filterByTimeframe(List<StatisticsModel> stats) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (selectedTimeframe) {
      case 'Day':
        cutoffDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Week':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        cutoffDate = DateTime(now.year, now.month - 1, now.day);
        break;
      default:
        cutoffDate = now.subtract(const Duration(days: 7));
    }

    return stats.where((stat) => stat.time.isAfter(cutoffDate)).toList()
      ..sort((a, b) => b.time.compareTo(a.time));
  }

  PostureAnalysis _analyzePostureData(List<StatisticsModel> stats) {
    if (stats.isEmpty) {
      return PostureAnalysis(
        goodPostureCount: 0,
        neutralPostureCount: 0,
        poorPostureCount: 0,
        goodPosturePercentage: 0,
        neutralPosturePercentage: 0,
        poorPosturePercentage: 0,
        dailyData: [],
        hourlyData: [],
        averageScore: 0,
        trend: 'neutral',
        trendPercentage: 0,
        totalGoodPostureTime: Duration.zero,
        averageSessionTime: Duration.zero,
      );
    }

    // NEW LOGIC: Messages = Bad Posture (0 score), Gaps = Good Posture
    // All messages indicate poor posture since they're only sent when posture is incorrect
    int poorCount = stats.length; // Every message = poor posture

    // Calculate good posture periods from gaps between messages
    List<Duration> goodPosturePeriods = [];
    Duration totalGoodTime = Duration.zero;

    if (stats.length > 1) {
      stats.sort((a, b) => a.time.compareTo(b.time)); // Sort chronologically

      for (int i = 0; i < stats.length - 1; i++) {
        Duration gap = stats[i + 1].time.difference(stats[i].time);

        // Consider gaps between 1 minute and 2 hours as good posture periods
        if (gap.inMinutes >= 1 && gap.inHours <= 2) {
          goodPosturePeriods.add(gap);
          totalGoodTime += gap;
        }
      }
    }

    // Calculate good posture "sessions" (every 15 minutes of good posture = 1 session)
    int goodCount = (totalGoodTime.inMinutes / 15).floor();
    int neutralCount = 0; // We don't have neutral in this simple model

    // Calculate percentages based on time, not message count
    int totalMinutes = poorCount * 2 +
        totalGoodTime.inMinutes; // Assume each poor message = 2 min
    double goodPercentage =
        totalMinutes > 0 ? (totalGoodTime.inMinutes / totalMinutes) * 100 : 0;
    double poorPercentage =
        totalMinutes > 0 ? ((poorCount * 2) / totalMinutes) * 100 : 0;
    double neutralPercentage = 0;

    // Calculate daily data with new logic
    final dailyData = _calculateDailyDataFromGaps(stats);

    // Calculate hourly data with new logic
    final hourlyData = _calculateHourlyDataFromGaps(stats);

    // Calculate average score (good time percentage)
    final averageScore = goodPercentage;

    // Calculate trend
    final trendData = _calculateTrend(dailyData);

    return PostureAnalysis(
      goodPostureCount: goodCount,
      neutralPostureCount: neutralCount,
      poorPostureCount: poorCount,
      goodPosturePercentage: goodPercentage,
      neutralPosturePercentage: neutralPercentage,
      poorPosturePercentage: poorPercentage,
      dailyData: dailyData,
      hourlyData: hourlyData,
      averageScore: averageScore,
      trend: trendData['trend'],
      trendPercentage: trendData['percentage'],
      totalGoodPostureTime: totalGoodTime,
      averageSessionTime: goodPosturePeriods.isEmpty
          ? Duration.zero
          : Duration(
              minutes: goodPosturePeriods
                      .map((d) => d.inMinutes)
                      .reduce((a, b) => a + b) ~/
                  goodPosturePeriods.length),
    );
  }

  // Calculate daily posture data from message gaps
  List<DailyPostureData> _calculateDailyDataFromGaps(
      List<StatisticsModel> stats) {
    if (stats.length < 2) return [];

    stats.sort((a, b) => a.time.compareTo(b.time));

    final Map<String, DailyPostureData> dailyData = {};

    // Process each day
    for (int i = 0; i < stats.length - 1; i++) {
      final currentMsg = stats[i];
      final nextMsg = stats[i + 1];
      final gap = nextMsg.time.difference(currentMsg.time);

      // If gap is reasonable (1 min to 2 hours), consider it good posture time
      if (gap.inMinutes >= 1 && gap.inHours <= 2) {
        final dateKey =
            '${currentMsg.time.year}-${currentMsg.time.month}-${currentMsg.time.day}';

        if (dailyData[dateKey] == null) {
          dailyData[dateKey] = DailyPostureData(
            date: DateTime(currentMsg.time.year, currentMsg.time.month,
                currentMsg.time.day),
            score: 0,
            goodCount: 0,
            poorCount: 0,
          );
        }

        // Add good posture time (gap) and poor posture incident (message)
        final existingData = dailyData[dateKey]!;
        final totalGoodMinutes = existingData.goodCount + gap.inMinutes;
        final totalPoorCount = existingData.poorCount + 1;

        // Calculate score as percentage of good time
        final totalMinutes =
            totalGoodMinutes + (totalPoorCount * 2); // 2 min per poor incident
        final score =
            totalMinutes > 0 ? (totalGoodMinutes / totalMinutes) * 100 : 0.0;

        dailyData[dateKey] = DailyPostureData(
          date: existingData.date,
          score: score,
          goodCount: totalGoodMinutes,
          poorCount: totalPoorCount,
        );
      }
    }

    return dailyData.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  List<HourlyPostureData> _calculateHourlyDataFromGaps(
      List<StatisticsModel> stats) {
    if (stats.length < 2) return [];

    stats.sort((a, b) => a.time.compareTo(b.time));
    final Map<int, HourlyPostureData> hourlyData = {};

    for (int i = 0; i < stats.length - 1; i++) {
      final currentMsg = stats[i];
      final nextMsg = stats[i + 1];
      final gap = nextMsg.time.difference(currentMsg.time);

      if (gap.inMinutes >= 1 && gap.inHours <= 2) {
        final hour = currentMsg.time.hour;

        if (hourlyData[hour] == null) {
          hourlyData[hour] = HourlyPostureData(hour: hour, score: 0, count: 0);
        }

        final existing = hourlyData[hour]!;
        final newScore =
            gap.inMinutes > 30 ? 80.0 : 60.0; // Good gap = higher score
        final avgScore =
            (existing.score * existing.count + newScore) / (existing.count + 1);

        hourlyData[hour] = HourlyPostureData(
          hour: hour,
          score: avgScore,
          count: existing.count + 1,
        );
      }
    }

    return hourlyData.values.toList()..sort((a, b) => a.hour.compareTo(b.hour));
  }

  Map<String, dynamic> _calculateTrend(List<DailyPostureData> dailyData) {
    if (dailyData.length < 2) {
      return {'trend': 'stable', 'percentage': 0.0};
    }

    final recent = dailyData.takeLast(3).map((e) => e.score).toList();
    final older =
        dailyData.take(dailyData.length - 3).map((e) => e.score).toList();

    if (recent.isEmpty || older.isEmpty) {
      return {'trend': 'stable', 'percentage': 0.0};
    }

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;

    final difference = recentAvg - olderAvg;
    final percentage = olderAvg == 0 ? 0 : (difference / olderAvg) * 100;

    String trend;
    if (percentage > 10) {
      trend = 'improving';
    } else if (percentage < -10) {
      trend = 'declining';
    } else {
      trend = 'stable';
    }

    return {'trend': trend, 'percentage': percentage.abs()};
  }

  Future<void> deleteStatistics(int index) async {
    try {
      await _box.deleteAt(index);
      await fetchStatistics();
    } catch (e) {
      emit(StatisticsError('Failed to delete statistics: $e'));
    }
  }

  // Clear all statistics
  Future<void> clearAllStatistics() async {
    try {
      await _box.clear();
      await fetchStatistics();
    } catch (e) {
      emit(StatisticsError('Failed to clear statistics: $e'));
    }
  }

  @override
  Future<void> close() {
    _box.close();
    return super.close();
  }
}

extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
