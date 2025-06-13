// lib/views/reports/report_student.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:siginas/services/auth_service.dart'; // Import AuthService
import 'package:siginas/services/firestore_service.dart'; // Import FirestoreService
import 'package:siginas/services/storage_service.dart'; // Import StorageService
import 'package:image_picker/image_picker.dart'; // Import ImagePicker for image selection
import 'dart:io'; // Import dart:io for File type
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Import for image compression

class ReportStudent extends StatefulWidget {
  final String namaSiswa;
  final String nisnSiswa;
  final String studentId; // Parameter untuk ID dokumen siswa

  const ReportStudent({
    super.key,
    required this.namaSiswa,
    required this.nisnSiswa,
    required this.studentId, // Wajib diterima dari halaman sebelumnya (ReportsUser)
  });

  @override
  State<ReportStudent> createState() => _ReportStudentState();
}

class _ReportStudentState extends State<ReportStudent> {
  final _formKey = GlobalKey<FormState>();

  File? _gambarSebelumMakan;
  File? _gambarSesudahMakan;
  final TextEditingController _keteranganController = TextEditingController();

  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  Future<void> _ambilGambar(bool sebelumMakan) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: source, imageQuality: 75);

    if (image != null) {
      File? finalImageFile;

      if (await image.length() > 1000 * 1024) {
        print(
            'DEBUG (ReportStudent): Ukuran gambar besar (${(await image.length() / (1024 * 1024)).toStringAsFixed(2)} MB), melakukan kompresi...');

        // KOREKSI UTAMA DI SINI:
        // compressedFileResult akan menjadi File?
        XFile? compressedFileResult =
            await FlutterImageCompress.compressAndGetFile(
          image.path,
          '${image.path}_compressed.jpg',
          minWidth: 800,
          minHeight: 800,
          quality: 70,
        );

        // Cukup periksa apakah hasilnya tidak null. Jika tidak null, itu sudah File.
        // Tidak perlu existsSync() di sini karena compressedFileResult sudah File?
        if (compressedFileResult != null) {
          finalImageFile = compressedFileResult as File?;
        } else {
          // Fallback jika kompresi mengembalikan null (jarang terjadi)
          print(
              'DEBUG (ReportStudent): Kompresi mengembalikan null, menggunakan file asli.');
          finalImageFile = File(image.path);
        }

        print(
            'DEBUG (ReportStudent): Kompresi selesai. Ukuran baru: ${((finalImageFile?.lengthSync() ?? 0) / 1024).toStringAsFixed(2)} KB');
      } else {
        finalImageFile = File(image.path);
        print('DEBUG (ReportStudent): Gambar tidak perlu kompresi.');
      }

      if (!mounted) return;

      setState(() {
        if (sebelumMakan) {
          _gambarSebelumMakan = finalImageFile;
        } else {
          _gambarSesudahMakan = finalImageFile;
        }
      });
      print(
          'DEBUG (ReportStudent): Gambar dipilih dan diproses: ${finalImageFile?.path}');
    }
  }

  // Widget untuk area input gambar
  Widget _buildImageInput(String label, File? imageFile, bool sebelumMakan) {
    return InkWell(
      onTap: () => _ambilGambar(sebelumMakan),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: imageFile != null
            ? Image.file(imageFile, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700])),
                ],
              ),
      ),
    );
  }

  // Fungsi untuk mengirim laporan ke Firestore dan Storage
  Future<void> _kirimLaporan() async {
    if (_gambarSebelumMakan == null || _gambarSesudahMakan == null) {
      _showSnackBar('Harap ambil gambar sebelum dan sesudah makan.',
          isError: true);
      return;
    }
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      // Pastikan form sudah divalidasi
      _showSnackBar('Harap lengkapi semua field yang diperlukan.',
          isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String? schoolUid = AuthService().currentUser?.uid;
    if (schoolUid == null) {
      _showSnackBar('Pengguna tidak terautentikasi.', isError: true);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String? gambarSebelumUrl;
    String? gambarSesudahUrl;

    try {
      // 1. Unggah gambar sebelum makan ke Firebase Storage
      String pathSebelum =
          'daily_reports/$schoolUid/${widget.studentId}/sebelum_makan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      gambarSebelumUrl =
          await _storageService.uploadImage(_gambarSebelumMakan!, pathSebelum);
      if (gambarSebelumUrl == null) {
        throw Exception('Gagal unggah gambar sebelum makan');
      }
      print(
          'DEBUG (ReportStudent): Gambar Sebelum Makan URL: $gambarSebelumUrl');

      // 2. Unggah gambar sesudah makan ke Firebase Storage
      String pathSesudah =
          'daily_reports/$schoolUid/${widget.studentId}/sesudah_makan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      gambarSesudahUrl =
          await _storageService.uploadImage(_gambarSesudahMakan!, pathSesudah);
      if (gambarSesudahUrl == null) {
        throw Exception('Gagal unggah gambar sesudah makan');
      }
      print(
          'DEBUG (ReportStudent): Gambar Sesudah Makan URL: $gambarSesudahUrl');

      // 3. Siapkan data laporan untuk Firestore
      final Map<String, dynamic> reportData = {
        'nama_siswa': widget.namaSiswa,
        'nisn_siswa': widget.nisnSiswa,
        'gambar_sebelum_makan_url': gambarSebelumUrl,
        'gambar_sesudah_makan_url': gambarSesudahUrl,
        'keterangan': _keteranganController.text.trim(),
        'uploaded_by_uid': schoolUid,
        'report_date':
            FieldValue.serverTimestamp(), // Tanggal dan waktu laporan
      };

      // 4. Tambahkan laporan ke Firestore
      final String? errorMessage = await _firestoreService.addDailyReport(
        schoolUid,
        widget.studentId, // Gunakan studentId untuk path di Firestore
        reportData,
      );

      // Pastikan widget masih mounted sebelum update UI
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (errorMessage == null) {
        _showSnackBar('Laporan berhasil dikirim!');
        Navigator.pop(context); // Kembali ke halaman daftar siswa
      } else {
        _showSnackBar('Gagal mengirim laporan: $errorMessage', isError: true);
      }
    } catch (e) {
      print('DEBUG (ReportStudent): Error mengirim laporan: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Terjadi kesalahan saat mengirim laporan: ${e.toString()}',
          isError: true);
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
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Makan Bergizi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nama Siswa',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                initialValue: widget.namaSiswa,
                enabled: false,
                decoration: InputDecoration(
                  // Hapus 'const'
                  hintText: 'Nama siswa',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'NISN',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                initialValue: widget.nisnSiswa,
                enabled: false,
                decoration: InputDecoration(
                  // Hapus 'const'
                  hintText: 'NISN',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildImageInput('Sebelum Makan', _gambarSebelumMakan, true),
                  _buildImageInput('Sesudah Makan', _gambarSesudahMakan, false),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Keterangan',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _keteranganController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Masukkan detail informasi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Keterangan tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _kirimLaporan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Kirim Laporan',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
