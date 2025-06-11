import 'package:flutter/material.dart';
import 'package:siginas/views/registration_details.dart';
import 'package:siginas/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllPendingRegistrationsScreen extends StatefulWidget {
  const AllPendingRegistrationsScreen({super.key});

  @override
  State<AllPendingRegistrationsScreen> createState() =>
      _AllPendingRegistrationsScreenState();
}

class _AllPendingRegistrationsScreenState
    extends State<AllPendingRegistrationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Pendaftaran Tertunda'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService()
            .streamPendingRegistrations(), // Mengambil data dari Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && !snapshot.hasData) {
            print(
                'DEBUG (AllPendingRegScreen): Error loading registrations: ${snapshot.error}');
            return Center(
                child: Text('Gagal memuat pendaftaran: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print(
                'DEBUG (AllPendingRegScreen): Tidak ada pendaftaran tertunda yang tersedia.');
            return const Center(child: Text('Tidak ada pendaftaran tertunda.'));
          }

          final List<Map<String, dynamic>> registrations = snapshot.data!;

          return ListView.builder(
            itemCount: registrations.length,
            itemBuilder: (context, index) {
              final registration = registrations[index];
              return ListTile(
                title: Text(registration['nama_sekolah'] ??
                    'Nama Sekolah Tidak Tersedia'),
                subtitle:
                    Text(registration['alamat'] ?? 'Alamat Tidak Tersedia'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrationDetailScreen(
                        // Pastikan nama field cocok dengan struktur Firestore Anda
                        schoolName: registration['nama_sekolah'] ?? '',
                        address: registration['alamat'] ?? '',
                        numberOfStudents: registration['jumlah_siswa'] ?? 0,
                        email: registration['email'] ?? '',
                        npsn: registration['npsn'] ?? '',
                        schoolUid:
                            registration['uid'] ?? '', // Teruskan UID sekolah
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
