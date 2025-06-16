import 'package:flutter/material.dart';
import 'package:siginas/services/firestore_service.dart';
import 'package:siginas/views/reports/unreported_school.dart';

class ReportsAdmin extends StatefulWidget {
  final String role;
  const ReportsAdmin({super.key, required this.role});

  @override
  State<ReportsAdmin> createState() => _ReportsAdminState();
}

class _ReportsAdminState extends State<ReportsAdmin> {
  String? _selectedProvinsi;
  String? _selectedJenjang;
  DateTime? _selectedDate;

  // Fungsi untuk menampilkan date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Statistik Harian'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pantau perkembangan pengumpulan laporan makan bergizi secara nasional.',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            // Widget untuk menampilkan statistik nasional dari Firestore
            _buildNationalStatsCard(),
            const SizedBox(height: 16.0), // Jarak setelah statistik nasional

            // Bagian "Belum Lapor Harian"
            _buildUnreportedSchoolsSection(context),
            const SizedBox(height: 24.0),

            const Text('Daftar Laporan Sekolah',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Pilih Provinsi',
              ),
              items: <String>[
                'Semua Provinsi', // Opsi untuk menghapus filter
                'Aceh', 'Sumatera Utara', 'Sumatera Barat', 'Riau', 'Jambi',
                'Sumatera Selatan',
                'Bengkulu', 'Lampung', 'Kepulauan Bangka Belitung',
                'Kepulauan Riau',
                'DKI Jakarta', 'Jawa Barat', 'Jawa Tengah', 'DI Yogyakarta',
                'Jawa Timur',
                'Banten', 'Bali', 'Nusa Tenggara Barat', 'Nusa Tenggara Timur',
                'Kalimantan Barat', 'Kalimantan Tengah', 'Kalimantan Selatan',
                'Kalimantan Timur', 'Kalimantan Utara', 'Gorontalo',
                'Sulawesi Utara',
                'Sulawesi Tengah', 'Sulawesi Selatan', 'Sulawesi Tenggara',
                'Sulawesi Barat', 'Maluku', 'Maluku Utara', 'Papua',
                'Papua Barat'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProvinsi =
                      (value == 'Semua Provinsi') ? null : value;
                });
                // Memicu rebuild _buildSchoolReportsDataTableFromFirestore
              },
              value: _selectedProvinsi ?? 'Semua Provinsi',
            ),
            const SizedBox(height: 8.0),

            const SizedBox(height: 8.0), // Sesuaikan jarak
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Pilih Jenjang Sekolah',
              ),
              items: <String>['Semua Jenjang', 'SD', 'SMP', 'SMA']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedJenjang = (value == 'Semua Jenjang') ? null : value;
                });
                // Memicu rebuild _buildSchoolReportsDataTableFromFirestore
              },
              value: _selectedJenjang ?? 'Semua Jenjang',
            ),
            const SizedBox(height: 8.0),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: _selectedDate == null
                        ? 'Pilih Tanggal'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Menggunakan widget yang mengambil data dari Firestore
            _buildSchoolReportsDataTableFromFirestore(),
          ],
        ),
      ),
    );
  }

  // Widget _buildNationalStatsCard (tetap sama)
  Widget _buildNationalStatsCard() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirestoreService().streamNationalStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(
              'DEBUG (ReportsAdmin): Error loading national stats: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          print(
              'DEBUG (ReportsAdmin): No national stats data available or document is null.');
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final int totalSchools = data['total_schools_registered'] ?? 0;
        final int dailyReports = data['total_daily_reports_today'] ?? 0;

        print(
            'DEBUG (ReportsAdmin - NationalStats): Extracted Total Schools: $totalSchools, Daily Reports: $dailyReports');

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.home, size: 32),
                        const SizedBox(height: 8.0),
                        Text(
                          totalSchools.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const Text('Total Sekolah',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 32, color: Colors.green),
                        const SizedBox(height: 8.0),
                        Text(
                          dailyReports.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const Text('Sudah Lapor Hari Ini',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildUnreportedSchoolsSection (tetap sama)
  Widget _buildUnreportedSchoolsSection(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().streamUnreportedSchoolsToday(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(
              'DEBUG (ReportsAdmin): Error loading unreported schools: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final List<Map<String, dynamic>> unreportedSchools = snapshot.data!;
        final List<Map<String, dynamic>> limitedUnreported =
            unreportedSchools.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Belum Lapor Harian',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UnreportedSchoolScreen(),
                      ),
                    );
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: limitedUnreported.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final schoolData = limitedUnreported[index];
                return ListTile(
                  title: Text(schoolData['nama_sekolah'] ??
                      'Nama Sekolah Tidak Tersedia'),
                  subtitle:
                      Text(schoolData['alamat'] ?? 'Alamat Tidak Tersedia'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- Widget _buildSchoolReportsDataTableFromFirestore (mengambil data dari Firestore) ---
  Widget _buildSchoolReportsDataTableFromFirestore() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().streamFilteredSchools(
        provinsi: _selectedProvinsi,
        jenjang: _selectedJenjang,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(
              'DEBUG (ReportsAdmin): Error loading filtered schools for table: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('Tidak ada data sekolah yang cocok dengan filter.'));
        }

        final List<Map<String, dynamic>> schools = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Nama Sekolah')),
              DataColumn(label: Text('Provinsi')),
              DataColumn(label: Text('Total Siswa')),
              DataColumn(label: Text('Lapor Hari Ini')),
            ],
            rows: schools.map((data) {
              final String namaSekolah = data['nama_sekolah'] ?? 'N/A';
              final String provinsi = data['provinsi'] ?? 'N/A';
              final int totalSiswa = data['jumlah_siswa'] ?? 0;
              final bool schoolHasCompletedReport =
                  data['school_has_completed_daily_report'] ?? false;

              return DataRow(cells: [
                DataCell(Text(namaSekolah)),
                DataCell(Text(provinsi)),
                DataCell(Text(totalSiswa.toString())),
                DataCell(Icon(
                    schoolHasCompletedReport
                        ? Icons.check_circle_outline
                        : Icons.cancel,
                    color:
                        schoolHasCompletedReport ? Colors.green : Colors.red)),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}
