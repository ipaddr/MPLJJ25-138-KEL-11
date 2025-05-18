import 'package:flutter/material.dart';
import 'package:siginas/views/registration_details.dart';

class AllPendingRegistrationsScreen extends StatefulWidget {
  const AllPendingRegistrationsScreen(
      {super.key, required List<Map<String, dynamic>> allPendingRegistrations});

  @override
  State<AllPendingRegistrationsScreen> createState() =>
      _AllPendingRegistrationsScreenState();
}

class _AllPendingRegistrationsScreenState
    extends State<AllPendingRegistrationsScreen> {
  List<Map<String, dynamic>> allPendingRegistrations = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingRegistrations();
  }

  Future<void> _fetchPendingRegistrations() async {
    // Simulasi data sementara
    setState(() {
      allPendingRegistrations = [
        {
          'namaSekolah': 'SD Negeri 1 Jakarta',
          'alamat': 'Jakarta Pusat',
          'jumlahSiswa': 300,
          'email': 'sdn1@jakarta.go.id',
          'npsn': '10101010'
        },
        {
          'namaSekolah': 'SMP Negeri 3 Surabaya',
          'alamat': 'Surabaya Timur',
          'jumlahSiswa': 450,
          'email': 'smpn3@surabaya.go.id',
          'npsn': '20202020'
        },
        {
          'namaSekolah': 'SD Negeri 5 Bandung',
          'alamat': 'Bandung Barat',
          'jumlahSiswa': 350,
          'email': 'sdn5@bandung.go.id',
          'npsn': '10303030'
        },
        {
          'namaSekolah': 'SMA Negeri 2 Yogyakarta',
          'alamat': 'Yogyakarta Kota',
          'jumlahSiswa': 500,
          'email': 'sman2@yogyakarta.go.id',
          'npsn': '30404040'
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Pendaftaran Tertunda'),
      ),
      body: allPendingRegistrations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allPendingRegistrations.length,
              itemBuilder: (context, index) {
                final registration = allPendingRegistrations[index];
                return ListTile(
                  title: Text(registration['namaSekolah'] ?? 'Nama Sekolah'),
                  subtitle:
                      Text(registration['alamat'] ?? 'Alamat belum tersedia'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationDetailScreen(
                          schoolName: registration['namaSekolah'] ?? '',
                          address: registration['alamat'] ?? '',
                          numberOfStudents: registration['jumlahSiswa'] ?? 0,
                          email: registration['email'] ?? '',
                          npsn: registration['npsn'] ?? '',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
