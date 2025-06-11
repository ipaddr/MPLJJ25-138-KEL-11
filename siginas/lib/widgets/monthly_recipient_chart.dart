// lib/widgets/monthly_recipient_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:siginas/services/firestore_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyRecipientChart extends StatelessWidget {
  const MonthlyRecipientChart({super.key});

  // Fungsi pembantu untuk mendapatkan indeks bulan (untuk sorting)
  // Ini harus diletakkan di luar build method atau sebagai static method
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
      case 'Agu':
        return 7;
      case 'Sep':
        return 8;
      case 'Okt':
        return 9;
      case 'Nov':
        return 10;
      case 'Des':
        return 11;
      default:
        return 0; // Default ke Januari jika tidak dikenal
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirestoreService()
          .streamNationalStats(), // Mengambil dokumen 'summary'
      builder: (context, snapshot) {
        // --- LOGIKA UTAMA UNTUK OFFLINE AVALABILITY ---

        // 1. Prioritaskan Data: Jika ada data, tampilkan data tersebut, tidak peduli status koneksi/error
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!['monthly_growth_data'] != null) {
          final List<dynamic> chartDataRaw =
              snapshot.data!['monthly_growth_data'] as List<dynamic>;
          final List<Map<String, dynamic>> chartData =
              chartDataRaw.map((e) => e as Map<String, dynamic>).toList();

          // Mengurutkan data berdasarkan tahun dan bulan (penting untuk grafik)
          chartData.sort((a, b) {
            int yearA = a['year'] as int;
            int yearB = b['year'] as int;
            int monthIndexA = _getMonthIndex(a['month'] as String);
            int monthIndexB = _getMonthIndex(b['month'] as String);

            if (yearA != yearB) {
              return yearA.compareTo(yearB);
            }
            return monthIndexA.compareTo(monthIndexB);
          });

          // Konversi data Firestore ke format FlSpot
          final List<FlSpot> spots = [];
          double maxX = 0;
          double maxY = 0;
          double minY = double.infinity;

          // Peta untuk label X-axis (bulan dan tahun)
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

          // Tentukan interval Y-axis
          double intervalY = (maxY - minY) / 4;
          if (intervalY == 0 && maxY > 0) intervalY = maxY / 2;
          if (intervalY == 0) intervalY = 1;

          // Padding untuk Y-axis agar titik tidak menempel di batas
          double yAxisPadding = maxY * 0.1;
          if (yAxisPadding < 10 && maxY > 0) yAxisPadding = 10;
          double finalMinY = (minY - yAxisPadding).clamp(0.0, double.infinity);
          double finalMaxY = maxY + yAxisPadding;

          return Container(
            height: 250,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  horizontalInterval:
                      500, // Sesuaikan ini dengan skala siswa Anda
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
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
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
                      interval: intervalY.clamp(1.0, double.infinity),
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
                    dotData: const FlDotData(
                      show: true,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blueAccent.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 2. Handle Loading: Jika ConnectionState.waiting DAN belum ada data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // 3. Handle Error: Jika ada error DAN tidak ada data (misalnya, tidak ada cache)
        if (snapshot.hasError) {
          print(
              'DEBUG (ChartWidget): Error loading chart data: ${snapshot.error}');
          return Container(
            height: 200,
            color: Colors.grey[200],
            child:
                Center(child: Text('Gagal memuat grafik: ${snapshot.error}')),
          );
        }

        // 4. Handle No Data: Jika tidak ada data atau data kosong
        // (Ini akan tercapai jika StreamBuilder.hasData == false dan tidak ada error atau loading)
        return Container(
          height: 200,
          color: Colors.grey[200],
          child: const Center(child: Text('Data grafik belum tersedia.')),
        );
      },
    );
  }
}
