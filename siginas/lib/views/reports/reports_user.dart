import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siginas/views/reports/report_student.dart';
import 'package:siginas/widgets/navigation_bar.dart';

class ReportsUser extends StatefulWidget {
  final String role;
  const ReportsUser({super.key, required this.role});

  @override
  State<ReportsUser> createState() => _ReportsUserState();
}

class _ReportsUserState extends State<ReportsUser> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _studentList = [
    {'nama': 'Ahmad Dhani', 'nisn': '0051234567', 'sudahLapor': true},
    {'nama': 'Budi Santoso', 'nisn': '0051234568', 'sudahLapor': false},
    {'nama': 'Citra Dewi', 'nisn': '0051234569', 'sudahLapor': true},
    // Tambahkan data dummy siswa lainnya di sini
  ];

  int _selectedIndex = 1;

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/HomeScreen');
        break;
      case 1:
        if (widget.role == 'admin') {
          Navigator.pushNamed(context, '/ReportsAdmin');
        } else {
          Navigator.pushNamed(context, '/ReportsUser');
        }
        break;
      case 2:
        Navigator.pushNamed(context, '/ProfileScreen');
        break;
    }
  }

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
        // Tambahkan InkWell untuk keseluruhan card bisa diklik (opsional)
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportStudent(
                namaSiswa: student['nama'],
                nisnSiswa: student['nisn'],
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
                    student['nama'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('NISN: ${student['nisn']}',
                      style: const TextStyle(color: Colors.grey)),
                  _buildReportStatus(student['sudahLapor']),
                ],
              ),
              InkWell(
                // Tambahkan InkWell hanya untuk ikon panah
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportStudent(
                        namaSiswa: student['nama'],
                        nisnSiswa: student['nisn'],
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

  // Widget untuk menampilkan daftar siswa (akan diisi dari Firestore nanti)
  Widget _buildStudentList() {
    // Di masa depan, Anda akan mengganti ini dengan StreamBuilder untuk Firestore
    // Contoh (belum terhubung ke Firestore):
    return ListView.builder(
      itemCount: _studentList.length,
      itemBuilder: (context, index) {
        return _buildStudentItem(_studentList[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                // Implementasikan logika pencarian siswa jika diperlukan
                // Anda bisa memfilter _studentList berdasarkan nilai pencarian
                print('Mencari: $value');
              },
            ),
          ),
          Expanded(
            child: _buildStudentList(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        role: 'user', // Atur role sebagai user di halaman ini
        onItemSelected: _handleNavigation,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tambahkan logika untuk menambahkan laporan baru atau siswa baru
          print('Tombol Tambah Ditekan');
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
