import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/app_colors.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return PostureStatisticsScreen();
  }
}

class PostureStatisticsScreen extends StatefulWidget {
  @override
  _PostureStatisticsScreenState createState() =>
      _PostureStatisticsScreenState();
}

class _PostureStatisticsScreenState extends State<PostureStatisticsScreen> {
  String selectedTimeframe = 'Week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            // Header
            Text(
              'Posture Time',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 20),

            // Time filter tabs - Only Day and Week
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: ['Day', 'Week'].map((timeframe) {
                  bool isSelected = selectedTimeframe == timeframe;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => selectedTimeframe = timeframe),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
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
            ),
            SizedBox(height: 30),

            // Posture Time Chart - Only Good and Poor
            Text(
              'Posture Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 200,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Good', 'Poor'];
                          return Text(
                            titles[value.toInt()],
                            style: TextStyle(
                              color: AppColors.primaryTextColor,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    // Good Posture Bar
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(
                          toY: 80,
                          color: AppColors.primaryColor,
                          width: 40,
                          borderRadius: BorderRadius.circular(4))
                    ]),
                    // Poor Posture Bar
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                          toY: 30,
                          color: AppColors.thirdButtonColor,
                          width: 40,
                          borderRadius: BorderRadius.circular(4))
                    ]),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            // Summary Section
            Text(
              'Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard('Total Good\nPosture', '12h 30m'),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildSummaryCard('Avg. Posture\nScore', '85/100'),
                ),
              ],
            ),
            SizedBox(height: 15),
            _buildTrendCard(),
            SizedBox(height: 30),

            // Daily Breakdown - Only Good and Poor
            Text(
              'Daily Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 15),
            _buildBreakdownItem(Icons.check_circle, 'Good Posture', '10h 30m',
                AppColors.primaryColor),
            _buildBreakdownItem(Icons.cancel, 'Poor Posture', '2h 00m',
                AppColors.thirdButtonColor),
            SizedBox(height: 30),

            // Posture Quality Trends
            Text(
              'Posture Quality Trends',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Posture Score',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.n48,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '85',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Last 7 Days +5%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 80,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = [
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun'
                                ];
                                return Text(
                                  days[value.toInt()],
                                  style: TextStyle(
                                    color: AppColors.n48,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 80),
                              FlSpot(1, 85),
                              FlSpot(2, 75),
                              FlSpot(3, 90),
                              FlSpot(4, 85),
                              FlSpot(5, 88),
                              FlSpot(6, 92),
                            ],
                            isCurved: true,
                            color: AppColors.primaryColor,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Correlation with Health Metrics
            Text(
              'Correlation with Health Metrics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 15),
            _buildCorrelationCard('Posture vs. Activity', 'High',
                'Last 7 Days +10%', Colors.green),
            SizedBox(width: 15),
            _buildCorrelationCard('Posture vs. Pain', 'Low', '-5%', Colors.red),
            SizedBox(height: 30),

            // Personalized Insights
            Text(
              'Personalized Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Your posture score has improved by 5% over the last week. You spent 83% of your time in good posture. Consider incorporating more exercises that strengthen your core and back muscles to further reduce poor posture time.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.n48,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.n48,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.n48,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '+5%',
            style: TextStyle(
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
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
            ),
          ),
          Text(
            duration,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.n48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationCard(
      String title, String value, String change, Color changeColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.n48,
            ),
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),
              SizedBox(width: 10),
              Text(
                change,
                style: TextStyle(
                  fontSize: 14,
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Low', style: TextStyle(color: AppColors.n48, fontSize: 12)),
              Text('Medium',
                  style: TextStyle(color: AppColors.n48, fontSize: 12)),
              Text('High',
                  style: TextStyle(color: AppColors.n48, fontSize: 12)),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: value == 'High' ? 0.8 : 0.3,
            backgroundColor: AppColors.primaryBackgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ],
      ),
    );
  }
}
