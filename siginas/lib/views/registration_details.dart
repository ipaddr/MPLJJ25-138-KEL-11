import 'package:flutter/material.dart';
import 'package:siginas/services/firestore_service.dart';

class RegistrationDetailScreen extends StatelessWidget {
  final String schoolName;
  final String address;
  final int numberOfStudents;
  final String email;
  final String npsn;
  final String schoolUid;

  const RegistrationDetailScreen({
    super.key,
    required this.schoolName,
    required this.address,
    required this.numberOfStudents,
    required this.email,
    required this.npsn,
    required this.schoolUid,
  });

  // Fungsi untuk menerima pendaftaran
  Future<void> _acceptRegistration(BuildContext context) async {
    print('DEBUG (RegDetail): Menerima pendaftaran untuk UID: $schoolUid');
    final String? errorMessage = await FirestoreService()
        .updateSchoolVerificationStatus(
            schoolUid, true); // Set is_verified ke true

    if (errorMessage == null) {
      // Pastikan widget masih mounted sebelum menampilkan SnackBar dan pop
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran berhasil diterima!')),
      );
      Navigator.pop(
          context); // Kembali ke halaman sebelumnya (AllPendingRegistrationsScreen)
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menerima pendaftaran: $errorMessage')),
      );
    }
  }

  // Fungsi untuk menolak pendaftaran
  Future<void> _rejectRegistration(BuildContext context) async {
    print('DEBUG (RegDetail): Menolak pendaftaran untuk UID: $schoolUid');
    // Anda bisa set is_verified ke false lagi, atau tambahkan field status lain seperti 'rejected'
    final String? errorMessage = await FirestoreService()
        .updateSchoolVerificationStatus(schoolUid, false);

    if (errorMessage == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran berhasil ditolak!')),
      );
      Navigator.pop(context);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menolak pendaftaran: $errorMessage')),
      );
    }
  }

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
                  onPressed: () =>
                      _acceptRegistration(context), // Panggil fungsi terima
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Terima'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _rejectRegistration(context), // Panggil fungsi tolak
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
