// lib/views/reports/add_student_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:siginas/services/auth_service.dart';
import 'package:siginas/services/firestore_service.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nisnController = TextEditingController();
  // Untuk kelas, kita bisa menggunakan dropdown atau text field. Kita mulai dengan text field sederhana.
  final TextEditingController _kelasController = TextEditingController();

  String?
      _selectedJenisKelamin; // Untuk radio button atau dropdown Jenis Kelamin

  bool _isLoading = false;

  Future<void> _addStudent() async {
    if (_formKey.currentState!.validate()) {
      // Pastikan jenis kelamin dipilih
      if (_selectedJenisKelamin == null || _selectedJenisKelamin!.isEmpty) {
        _showSnackBar('Jenis kelamin tidak boleh kosong.', isError: true);
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final String? schoolUid = AuthService().currentUser?.uid;
      if (schoolUid == null) {
        _showSnackBar('Pengguna tidak terautentikasi.', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> studentData = {
        'nama': _namaController.text.trim(),
        'nisn': _nisnController.text.trim(),
        'kelas': _kelasController.text.trim(),
        'jenis_kelamin': _selectedJenisKelamin,
        'has_reported_today': false, // Default: belum lapor hari ini
        'is_active': true, // Default: siswa aktif
        'registered_at': FieldValue.serverTimestamp(), // Timestamp pendaftaran
      };

      final String? errorMessage = await _firestoreService.addStudent(
        schoolUid,
        studentData,
      );

      if (!mounted) return; // Cek mounted setelah async call

      setState(() {
        _isLoading = false;
      });

      if (errorMessage == null) {
        _showSnackBar('Siswa berhasil ditambahkan!');
        Navigator.pop(context); // Kembali ke ReportsUser
      } else {
        _showSnackBar('Gagal menambahkan siswa: $errorMessage', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nisnController.dispose();
    _kelasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Siswa Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Siswa',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama siswa tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nisnController,
                decoration: const InputDecoration(
                  labelText: 'NISN',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'NISN tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _kelasController,
                decoration: const InputDecoration(
                  labelText: 'Kelas (contoh: 1A, 5B)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Kelas tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16.0),
              const Text('Jenis Kelamin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Laki-laki'),
                      value: 'Laki-laki',
                      groupValue: _selectedJenisKelamin,
                      onChanged: (value) {
                        setState(() {
                          _selectedJenisKelamin = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Perempuan'),
                      value: 'Perempuan',
                      groupValue: _selectedJenisKelamin,
                      onChanged: (value) {
                        setState(() {
                          _selectedJenisKelamin = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _addStudent,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18.0),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Tambah Siswa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
