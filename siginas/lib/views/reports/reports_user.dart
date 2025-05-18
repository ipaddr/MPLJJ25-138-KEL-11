import 'package:flutter/material.dart';

class ReportsUser extends StatelessWidget {
  const ReportsUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan (Pengguna)'),
      ),
      body: const Center(
        child: Text('Tampilan Laporan untuk Pengguna'),
      ),
    );
  }
}
