import 'package:flutter/material.dart';
// import 'package:siginas/views/reports/reports_admin.dart';
// import 'package:siginas/views/reports/reports_user.dart';
import 'package:siginas/widgets/navigation_bar.dart';

class ProfileScreen extends StatefulWidget {
  final String role;
  const ProfileScreen({super.key, required this.role});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/HomeScreen');
        break;
      case 1:
        if (widget.role == 'admin') {
          Navigator.pushReplacementNamed(context, '/ReportsAdmin');
        } else {
          Navigator.pushReplacementNamed(context, '/ReportsUser');
        }
        break;
      case 2:
        // Tetap di halaman profil
        break;
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
                onPressed: () {
                  // Implementasikan logika logout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Contoh warna logout
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        role: 'admin', // Atur role sesuai kebutuhan atau ambil dari state
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
