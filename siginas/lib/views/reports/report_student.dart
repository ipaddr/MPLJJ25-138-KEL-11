import 'package:flutter/material.dart';

class ReportStudent extends StatefulWidget {
  final String namaSiswa;
  final String nisnSiswa;

  const ReportStudent({
    super.key,
    required this.namaSiswa,
    required this.nisnSiswa,
  });

  @override
  State<ReportStudent> createState() => _ReportStudentState();
}

class _ReportStudentState extends State<ReportStudent> {
  // Variabel untuk menyimpan gambar (nantinya akan diisi dengan path/file gambar)
  // For simplicity, we'll use placeholders for now
  String? _gambarSebelumMakan;
  String? _gambarSesudahMakan;
  TextEditingController _keteranganController = TextEditingController();

  // Fungsi untuk mengambil gambar (belum diimplementasikan)
  Future<void> _ambilGambar(bool sebelumMakan) async {
    // Implementasi pengambilan gambar dari kamera atau galeri
    // Setelah mendapatkan gambar, update _gambarSebelumMakan atau _gambarSesudahMakan
    print(
        'Mengambil gambar untuk ${sebelumMakan ? "sebelum" : "sesudah"} makan');
    setState(() {
      if (sebelumMakan) {
        _gambarSebelumMakan = 'gambar_sebelum.jpg'; // Placeholder
      } else {
        _gambarSesudahMakan = 'gambar_sesudah.jpg'; // Placeholder
      }
    });
  }

  // Widget untuk area input gambar
  Widget _buildImageInput(String label, String? imagePath, bool sebelumMakan) {
    return InkWell(
      onTap: () => _ambilGambar(sebelumMakan),
      child: Container(
        width: 150, // Sesuaikan lebar
        height: 150, // Sesuaikan tinggi
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: imagePath != null
            ? Center(
                child: Text('Gambar Terpilih')) // Ganti dengan tampilan gambar
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 40),
                  const SizedBox(height: 8),
                  Text(label, textAlign: TextAlign.center),
                ],
              ),
      ),
    );
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama Siswa',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              initialValue: widget.namaSiswa,
              enabled: false, // Tidak bisa diedit
              decoration: InputDecoration(
                hintText: 'Masukkan nama siswa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'NISN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              initialValue: widget.nisnSiswa,
              enabled: false, // Tidak bisa diedit
              decoration: InputDecoration(
                hintText: 'Masukkan NISN',
                border: OutlineInputBorder(),
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _keteranganController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan detail informasi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implementasikan logika kirim laporan
                  print('Nama: ${widget.namaSiswa}');
                  print('NISN: ${widget.nisnSiswa}');
                  print('Gambar Sebelum: $_gambarSebelumMakan');
                  print('Gambar Sesudah: $_gambarSesudahMakan');
                  print('Keterangan: ${_keteranganController.text}');
                  // Navigasi atau proses data lebih lanjut
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Sesuaikan warna tombol
                  foregroundColor: Colors.white,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Kirim Laporan', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
