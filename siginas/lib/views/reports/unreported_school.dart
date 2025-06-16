// lib/views/reports/unreported_school.dart
import 'package:flutter/material.dart';
import 'package:siginas/services/firestore_service.dart';

class UnreportedSchoolScreen extends StatefulWidget {
  const UnreportedSchoolScreen({super.key});

  @override
  State<UnreportedSchoolScreen> createState() => _UnreportedSchoolScreenState();
}

class _UnreportedSchoolScreenState extends State<UnreportedSchoolScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sekolah Belum Lapor Hari Ini'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().streamUnreportedSchoolsToday(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Logika untuk mendukung offline:
          // Tampilkan data jika ada, meskipun ada error (misalnya offline)
          if (snapshot.hasError && !snapshot.hasData) {
            print(
                'DEBUG (UnreportedSchoolScreen): Error loading unreported schools: ${snapshot.error}');
            return Center(
                child: Text('Gagal memuat daftar: ${snapshot.error}'));
          }
          // Jika tidak ada data sama sekali (baik dari server maupun cache)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print(
                'DEBUG (UnreportedSchoolScreen): Semua sekolah sudah lapor hari ini!');
            return const Center(
                child: Text('Semua sekolah sudah lapor hari ini.'));
          }

          final List<Map<String, dynamic>> unreportedSchools = snapshot.data!;

          return ListView.separated(
            itemCount: unreportedSchools.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final schoolData = unreportedSchools[index];
              return ListTile(
                title: Text(schoolData['nama_sekolah'] ??
                    'Nama Sekolah Tidak Tersedia'),
                subtitle: Text(schoolData['alamat'] ?? 'Alamat Tidak Tersedia'),
              );
            },
          );
        },
      ),
    );
  }
}
