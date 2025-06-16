import 'package:flutter/material.dart';
import 'package:siginas/views/reports/add_student.dart';
import 'package:siginas/views/reports/report_student.dart';
import 'package:siginas/services/firestore_service.dart';
import 'package:siginas/services/auth_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsUser extends StatefulWidget {
  final String role;
  const ReportsUser({super.key, required this.role});

  @override
  State<ReportsUser> createState() => _ReportsUserState();
}

class _ReportsUserState extends State<ReportsUser> {
  final TextEditingController _searchController = TextEditingController();
  // Widget untuk menampilkan status laporan
  Widget _buildReportStatus(bool sudahLapor) {
    return Row(
      children: [
        Icon(
          sudahLapor ? Icons.check_circle : Icons.cancel,
          color: sudahLapor ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(sudahLapor ? 'Sudah Lapor' : 'Belum Lapor'),
      ],
    );
  }

  // Widget untuk menampilkan item daftar siswa
  Widget _buildStudentItem(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportStudent(
                namaSiswa: student['nama'] ?? '',
                nisnSiswa: student['nisn'] ?? '',
                studentId: student['id'] ?? '', // Teruskan ID dokumen siswa
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['nama'] ?? 'Nama Tidak Tersedia',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('NISN: ${student['nisn'] ?? 'N/A'}',
                      style: const TextStyle(color: Colors.grey)),
                  // Asumsi 'sudahLapor' adalah field boolean di Firestore atau dihitung secara dinamis
                  // Untuk saat ini, kita bisa menggunakan placeholder
                  _buildReportStatus(student['has_reported_today'] ??
                      false), // Ganti dengan field yang benar
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportStudent(
                        namaSiswa: student['nama'] ?? '',
                        nisnSiswa: student['nisn'] ?? '',
                        studentId: student['id'] ?? '',
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget untuk menampilkan daftar siswa dari Firestore ---
  Widget _buildStudentList(String schoolUid) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().streamStudents(schoolUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Logika untuk mendukung offline:
        // Tampilkan data jika ada, meskipun ada error (misalnya offline)
        if (snapshot.hasError && !snapshot.hasData) {
          print(
              'DEBUG (ReportsUser): Error loading students: ${snapshot.error}');
          return Center(
              child: Text('Error memuat daftar siswa: ${snapshot.error}'));
        }
        // Jika tidak ada data sama sekali (baik dari server maupun cache)
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('DEBUG (ReportsUser): Tidak ada data siswa untuk sekolah ini.');
          return const Center(child: Text('Tidak ada siswa yang terdaftar.'));
        }

        List<Map<String, dynamic>> studentData = snapshot.data!;

        // --- Implementasi Pencarian/Filter Lokal ---
        if (_searchController.text.isNotEmpty) {
          String query = _searchController.text.toLowerCase();
          studentData = studentData.where((student) {
            return (student['nama']?.toLowerCase() ?? '').contains(query) ||
                (student['nisn']?.toLowerCase() ?? '').contains(query);
          }).toList();
        }

        if (studentData.isEmpty && _searchController.text.isNotEmpty) {
          return const Center(
              child: Text('Tidak ada siswa yang cocok dengan pencarian Anda.'));
        }

        return ListView.builder(
          itemCount: studentData.length,
          itemBuilder: (context, index) {
            return _buildStudentItem(studentData[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = AuthService().currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Laporan Makan Bergizi')),
        body: const Center(
            child: Text('Pengguna tidak login atau UID tidak tersedia.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Makan Bergizi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Tambahkan aksi menu lainnya jika perlu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari siswa...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  // Memanggil setState agar _buildStudentList me-render ulang dengan filter baru
                });
              },
            ),
          ),
          Expanded(
            child: _buildStudentList(currentUserId), // Meneruskan UID sekolah
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke AddStudentScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentScreen()),
          );
          print('DEBUG (ReportsUser): Tombol Tambah Siswa Ditekan.');
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
