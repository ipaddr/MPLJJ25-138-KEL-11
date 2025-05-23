import 'package:flutter/material.dart';
import 'package:siginas/services/auth_service.dart';
import 'package:siginas/views/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String role;
  const ProfileScreen({super.key, required this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _logout() async {
    print('DEBUG: Memulai proses logout dari ProfileScreen.');
    try {
      await AuthService().signOut();
      print(
          'DEBUG: AuthService().signOut() berhasil dipanggil. Sesi telah diakhiri.');

      // Setelah logout, secara paksa navigasi kembali ke root dan tampilkan LoginScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) =>
            false, // Ini akan menghapus semua route sebelumnya
      );

      print('DEBUG: Navigasi paksa ke LoginScreen selesai.');
    } catch (e) {
      print('DEBUG: Error saat logout di ProfileScreen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Sekolah'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.school, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'SMA Negeri 1 Contoh',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Text('ID : 12345678',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            const Text('Alamat', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Jl. Pendidikan No. 123, Kota Contoh'),
            const SizedBox(height: 16.0),
            const Text('Jumlah Siswa',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('1,250 Siswa'),
            const SizedBox(height: 16.0),
            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('sman1contoh@edu.id'),
            const SizedBox(height: 16.0),
            const Text('Tahun Akreditasi',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('2025'),
            const SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implementasikan logika edit profil
                },
                child: const Text('Edit Profile'),
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout, // Panggil fungsi logout
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
