// lib/widgets/monthly_recipient_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:siginas/services/firestore_service.dart';

class MonthlyRecipientChart extends StatelessWidget {
  const MonthlyRecipientChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirestoreService().streamNationalStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Container(
            height: 200,
            color: Colors.grey[200],
            child:
                Center(child: Text('Gagal memuat grafik: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!['monthly_growth_data'] == null) {
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: Text('Data grafik belum tersedia.')),
          );
        }

        final List<dynamic> chartDataRaw =
            snapshot.data!['monthly_growth_data'] as List<dynamic>;
        final List<Map<String, dynamic>> chartData =
            chartDataRaw.cast<Map<String, dynamic>>();

        chartData.sort((a, b) {
          int yearA = a['year'] as int;
          int yearB = b['year'] as int;
          int monthIndexA = _getMonthIndex(a['month']);
          int monthIndexB = _getMonthIndex(b['month']);
          if (yearA != yearB) return yearA.compareTo(yearB);
          return monthIndexA.compareTo(monthIndexB);
        });

        final List<FlSpot> spots = [];
        double maxX = 0;
        double maxY = 0;
        double minY = double.infinity;
        List<String> xLabels = [];

        for (int i = 0; i < chartData.length; i++) {
          final dataPoint = chartData[i];
          final double students =
              (dataPoint['students_receiving_meals'] as num?)?.toDouble() ??
                  0.0;
          spots.add(FlSpot(i.toDouble(), students));
          if (i > maxX) maxX = i.toDouble();
          if (students > maxY) maxY = students;
          if (students < minY) minY = students;
          xLabels.add('${dataPoint['month']} ${dataPoint['year']}');
        }

        double intervalY = (maxY - minY) / 4;
        if (intervalY == 0 && maxY > 0) intervalY = maxY / 2;
        if (intervalY == 0) intervalY = 1;

        double yAxisPadding = maxY * 0.1;
        if (yAxisPadding < 10 && maxY > 0) yAxisPadding = 10;
        double finalMinY = (minY - yAxisPadding).clamp(0.0, double.infinity);
        double finalMaxY = maxY + yAxisPadding;

        return Container(
          height: 250,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: intervalY,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 0.5,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 0.5,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < xLabels.length &&
                          value.toInt() >= 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            xLabels[value.toInt()],
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: intervalY.clamp(1.0, double.infinity),
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              minX: 0,
              maxX: maxX,
              minY: finalMinY,
              maxY: finalMaxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blueAccent,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blueAccent.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getMonthIndex(String monthName) {
    switch (monthName) {
      case 'Jan':
        return 0;
      case 'Feb':
        return 1;
      case 'Mar':
        return 2;
      case 'Apr':
        return 3;
      case 'May':
        return 4;
      case 'Jun':
        return 5;
      case 'Jul':
        return 6;
      case 'Aug':
        return 7;
      case 'Sept':
        return 8;
      case 'Oct':
        return 9;
      case 'Nov':
        return 10;
      case 'Dec':
        return 11;
      default:
        return 0;
    }
  }
}
