import 'package:flutter/material.dart';

class RegistrationDetailScreen extends StatelessWidget {
  final String schoolName;
  final String address;
  final int numberOfStudents;
  final String email;
  final String npsn;

  const RegistrationDetailScreen({
    super.key,
    required this.schoolName,
    required this.address,
    required this.numberOfStudents,
    required this.email,
    required this.npsn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pendaftaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pendaftaran',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildDetailItem('Nama Sekolah', schoolName),
            _buildDetailItem('Alamat', address),
            _buildDetailItem('Jumlah Siswa', '$numberOfStudents Siswa'),
            _buildDetailItem('Email', email),
            _buildDetailItem('NPSN', npsn),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implementasikan logika terima pendaftaran
                    print('Pendaftaran diterima untuk $schoolName');
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Terima'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implementasikan logika tolak pendaftaran
                    print('Pendaftaran ditolak untuk $schoolName');
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tolak'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
