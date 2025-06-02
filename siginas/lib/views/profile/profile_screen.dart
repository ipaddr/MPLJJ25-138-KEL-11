// lib/views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:siginas/services/auth_service.dart';
import 'package:siginas/services/firestore_service.dart';
import 'package:siginas/views/auth/login_screen.dart';
import 'package:siginas/views/profile/edit_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    final String? currentUserId = AuthService().currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil Sekolah')),
        body: const Center(
          child: Text('Pengguna tidak login. Silakan login kembali.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Sekolah'),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: FirestoreService().streamUserProfile(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(
                'DEBUG (ProfileScreen): Error loading profile: ${snapshot.error}');
            return Center(child: Text('Gagal memuat profil: ${snapshot.error}'));
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            print(
                'DEBUG (ProfileScreen): Profil tidak ditemukan atau kosong untuk UID: $currentUserId');
            return const Center(
                child: Text('Profil tidak ditemukan atau belum lengkap.'));
          }

          final userData = snapshot.data!;
          final String namaSekolah = userData['nama_sekolah'] ?? 'N/A';
          final String alamat = userData['alamat'] ?? 'N/A';
          final int jumlahSiswa = userData['jumlah_siswa'] ?? 0;
          final String email = userData['email'] ?? 'N/A';
          final String npsn = userData['npsn'] ?? 'N/A';
          final int tahunAkreditasi = userData['tahun_akreditasi'] ?? 0;
          final String? profileImageUrl =
              userData['profile_image_url'] as String?; // Ambil URL gambar

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                            // Ganti NetworkImage dengan CachedNetworkImageProvider
                            ? CachedNetworkImageProvider(profileImageUrl) as ImageProvider
                            : null, // Jika tidak ada URL, tidak ada gambar
                        child: profileImageUrl == null || profileImageUrl.isEmpty
                            ? Icon(Icons.school, size: 40, color: Colors.grey[600])
                            : null,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        namaSekolah,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text('ID : ${npsn == 'N/A' ? 'Belum Ada' : npsn}',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                const Text('Alamat', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(alamat),
                const SizedBox(height: 16.0),
                const Text('Jumlah Siswa', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$jumlahSiswa Siswa'),
                const SizedBox(height: 16.0),
                const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(email),
                const SizedBox(height: 16.0),
                const Text('Tahun Akreditasi', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(tahunAkreditasi == 0 ? 'N/A' : tahunAkreditasi.toString()),
                const SizedBox(height: 32.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(userData: userData),
                        ),
                      );
                      print(
                          'DEBUG (ProfileScreen): Tombol Edit Profile ditekan. Navigasi ke EditProfileScreen.');
                    },
                    child: const Text('Edit Profile'),
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}