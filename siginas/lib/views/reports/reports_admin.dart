import 'package:flutter/material.dart';
// import 'package:siginas/views/reports/belum_upload_screen.dart';

class ReportsAdmin extends StatefulWidget {
  final String role;
  const ReportsAdmin({super.key, required this.role});

  @override
  State<ReportsAdmin> createState() => _ReportsAdminState();
}

class _ReportsAdminState extends State<ReportsAdmin> {
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
            IntrinsicHeight(
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
                          children: const [
                            Icon(Icons.home, size: 32),
                            SizedBox(height: 8.0),
                            Text(
                              '2,458',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Total Sekolah',
                              style: TextStyle(color: Colors.grey),
                            ),
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
                          children: const [
                            Icon(
                              Icons.check_circle_outline,
                              size: 32,
                              color: Colors.green,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              '1,873',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Sudah Lapor Hari Ini',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Jumlah Laporan Harian (7 Hari Terakhir)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Container(
              height: 150.0,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Center(child: Text('Line Chart Visualization')),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Belum Upload',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                // TextButton(
                //   onPressed: () {
                //     // Navigasi ke halaman Belum Upload
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => const BelumUploadScreen()),
                //     );
                //   },
                //   child: const Text('See All'),
                // ),
              ],
            ),
            const SizedBox(height: 8.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // Placeholder count
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      'SMP Negeri ${index + 1} Padang'), // Placeholder data
                  subtitle: const Text('Padang'), // Placeholder data
                  // trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Handle tap to view detail if needed
                  },
                );
              },
            ),
            const SizedBox(height: 24.0),
            const Text('Daftar Laporan Sekolah',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Pilih Provinsi',
              ),
              items: <String>['DKI Jakarta', 'Jawa Barat'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                // Handle change
              },
            ),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Pilih Kota',
              ),
              items: <String>['Jakarta Pusat', 'Bandung'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                // Handle change
              },
            ),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Pilih Jenjang Sekolah',
              ),
              items: <String>['SD', 'SMP'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                // Handle change
              },
            ),
            const SizedBox(height: 8.0),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'mm/dd/yyyy',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nama Sekolah')),
                  DataColumn(label: Text('Provinsi')),
                  DataColumn(label: Text('Jenjang')),
                  DataColumn(label: Text('Total Siswa')),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('SDN 1 Jakarta')),
                    DataCell(Text('DKI Jakarta')),
                    DataCell(Text('SD')),
                    DataCell(Text('100')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('SMP 2 Bandung')),
                    DataCell(Text('Jawa Barat')),
                    DataCell(Text('SMP')),
                    DataCell(Text('400')),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
