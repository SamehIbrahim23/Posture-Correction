import 'package:camera_stream/feature/statistics/presentation/logic/statistical_cubit.dart';
import 'package:camera_stream/feature/statistics/presentation/logic/statistical_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_colors.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const PostureStatisticsScreen();
  }
}

class PostureStatisticsScreen extends StatefulWidget {
  const PostureStatisticsScreen({super.key});

  @override
  State<PostureStatisticsScreen> createState() =>
      _PostureStatisticsScreenState();
}

class _PostureStatisticsScreenState extends State<PostureStatisticsScreen> {
  @override
  initState() {
    super.initState();
    context.read<StatisticsCubit>().fetchStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StatisticsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<StatisticsCubit>().fetchStatistics(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is StatisticsLoaded) {
            return _buildStatisticsContent(context, state);
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildStatisticsContent(BuildContext context, StatisticsLoaded state) {
    final analysis = state.analysis;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Posture Analytics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTrendColor(analysis.trend),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${analysis.trend.toUpperCase()} ${analysis.trendPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Time filter tabs
          BlocBuilder<StatisticsCubit, StatisticsState>(
            builder: (context, state) {
              final cubit = context.read<StatisticsCubit>();
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: ['Day', 'Week', 'Month'].map((timeframe) {
                    bool isSelected = cubit.selectedTimeframe == timeframe;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => cubit.changeTimeframe(timeframe),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            timeframe,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.primaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          // Posture Time Chart
          const Text(
            'Posture Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: analysis.goodPostureCount + analysis.poorPostureCount == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.analytics_outlined,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'No posture data available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String label;
                            switch (groupIndex) {
                              case 0:
                                label =
                                    'Good: ${analysis.goodPostureCount} sessions';
                                break;
                              case 1:
                                label =
                                    'Poor: ${analysis.poorPostureCount} sessions';
                                break;
                              default:
                                label = '';
                            }
                            return BarTooltipItem(
                              label,
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const titles = ['Good', 'Poor'];
                              return Text(
                                titles[value.toInt()],
                                style: const TextStyle(
                                  color: AppColors.primaryTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [
                          BarChartRodData(
                            toY: analysis.goodPosturePercentage,
                            color: AppColors.primaryColor,
                            width: 40,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ]),
                        BarChartGroupData(x: 1, barRods: [
                          BarChartRodData(
                            toY: analysis.poorPosturePercentage,
                            color: AppColors.thirdButtonColor,
                            width: 40,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ]),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 30),
          // Summary Section
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Good\nPosture',
                  _formatDuration(analysis.totalGoodPostureTime),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSummaryCard(
                  'Avg. Posture\nScore',
                  '${analysis.averageScore.toStringAsFixed(0)}/100',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildTrendCard(analysis.trend, analysis.trendPercentage),
          const SizedBox(height: 30),

          // Daily Breakdown
          const Text(
            'Session Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildBreakdownItem(
            Icons.check_circle,
            'Good Posture Sessions',
            '${analysis.goodPostureCount} sessions',
            AppColors.primaryColor,
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.thirdButtonColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.thirdButtonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cancel,
                      color: AppColors.thirdButtonColor, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Poor Posture Sessions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Needs attention',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.thirdButtonColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.thirdButtonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${analysis.poorPostureCount} sessions',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.thirdButtonColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Posture Quality Trends
          const Text(
            'Posture Quality Trends',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Posture Score Over Time',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.n48,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      analysis.averageScore.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${analysis.trend} ${analysis.trendPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getTrendColor(analysis.trend),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 80,
                  child: analysis.dailyData.isEmpty
                      ? Center(
                          child: Text(
                            'Not enough data for trend analysis',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >=
                                        analysis.dailyData.length) {
                                      return const Text('');
                                    }
                                    final date =
                                        analysis.dailyData[value.toInt()].date;
                                    return Text(
                                      '${date.day}/${date.month}',
                                      style: const TextStyle(
                                        color: AppColors.n48,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: analysis.dailyData
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  return FlSpot(
                                      entry.key.toDouble(), entry.value.score);
                                }).toList(),
                                isCurved: true,
                                color: AppColors.primaryColor,
                                barWidth: 3,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: AppColors.primaryColor,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color:
                                      AppColors.primaryColor.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Personalized Insights
          const Text(
            'Personalized Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _generateInsights(analysis),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.n48,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'improving':
        return Colors.green;
      case 'declining':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  String _generateInsights(PostureAnalysis analysis) {
    if (analysis.poorPostureCount == 0) {
      return 'Excellent! No posture correction alerts detected. Keep maintaining your good posture habits.';
    }

    if (analysis.averageScore >= 80) {
      return 'Great job! You have ${analysis.poorPostureCount} posture alerts but maintained good posture ${analysis.averageScore.toStringAsFixed(0)}% of the time. The gaps between alerts show you\'re responding well to corrections.';
    } else if (analysis.averageScore >= 60) {
      return 'Good progress! You received ${analysis.poorPostureCount} posture correction alerts. Try to maintain good posture for longer periods between corrections to improve your score.';
    } else {
      return 'Keep working on it! You received ${analysis.poorPostureCount} posture alerts. Focus on maintaining proper hip position and neck alignment. The frequent alerts suggest you need to be more mindful of your posture throughout the day.';
    }
  }
}

Widget _buildSummaryCard(String title, String value) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.n48,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTextColor,
          ),
        ),
      ],
    ),
  );
}

Widget _buildTrendCard(String trend, double percentage) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trend,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.n48,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    ),
  );
}

Widget _buildBreakdownItem(
    IconData icon, String title, String duration, Color color) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
        ),
        Text(
          duration,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.n48,
          ),
        ),
      ],
    ),
  );
}
