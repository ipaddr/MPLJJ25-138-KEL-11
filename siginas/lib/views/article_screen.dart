import 'package:flutter/material.dart';

class ArticleScreen extends StatelessWidget {
  final String title;
  final String authorDate;
  final String readTime;
  final String imageUrl; // Jika ada gambar dari URL
  final String content;

  const ArticleScreen({
    super.key,
    required this.title,
    required this.authorDate,
    required this.readTime,
    this.imageUrl = '', // Nilai default jika tidak ada URL gambar
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kembali'), // Judul "Kembali" sesuai gambar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Text(
                  authorDate,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 8.0),
                const Text(
                  '•',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 8.0),
                Text(
                  readTime,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Widget untuk menampilkan gambar ilustrasi
            Container(
              width: double.infinity,
              height: 200.0,
              color:
                  Colors.grey[300], // Placeholder warna abu-abu seperti gambar
              child: Center(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('[Gambar Ilustrasi Gizi Anak]');
                        },
                      )
                    : const Text('[Gambar Ilustrasi Gizi Anak]'),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              content,
              style: const TextStyle(fontSize: 16.0, height: 1.5),
            ),
            const SizedBox(height: 32.0),
            // Bagian "Sumber Protein Terbaik" akan menjadi bagian dari konten
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.share),
            const SizedBox(width: 8.0),
            const Text('Bagikan'),
          ],
        ),
      ),
    );
  }
}
