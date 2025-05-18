import 'package:flutter/material.dart';

class ReportsAdmin extends StatelessWidget {
  const ReportsAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan (Admin)'),
      ),
      body: const Center(
        child: Text('Tampilan Laporan untuk Admin'),
      ),
    );
  }
}
