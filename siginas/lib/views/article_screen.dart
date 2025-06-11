import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Pastikan import ini ada

class ArticleScreen extends StatelessWidget {
  final String title;
  final String author; // <-- Menggunakan "author" dari Firestore
  final String
      formattedPublishDate; // <-- Menggunakan nama yang lebih jelas untuk tanggal publikasi
  final String? imageUrl;
  final String content;

  const ArticleScreen({
    super.key,
    required this.title,
    required this.author, // <-- required: author
    required this.formattedPublishDate, // <-- required: tanggal publikasi yang sudah diformat
    this.imageUrl, // <-- imageUrl tetap nullable, tanpa default value
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
                // Menampilkan Author dan Tanggal Publikasi
                Text(
                  '$author • $formattedPublishDate', // Menggabungkan Author dan Tanggal
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 8.0),
                const Text(
                  '•', // Pemisah antara tanggal dan waktu baca
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 8.0),
              ],
            ),
            const SizedBox(height: 16.0),
            // Widget untuk menampilkan gambar ilustrasi
            Container(
              width: double.infinity,
              height: 200.0,
              color: Colors.grey[300], // Placeholder warna abu-abu
              child: Center(
                // Menggunakan CachedNetworkImage untuk caching dan penanganan null/empty
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Center(child: Icon(Icons.broken_image)),
                      )
                    : const Text(
                        '[Gambar Ilustrasi Artikel]'), // Teks placeholder jika tidak ada URL
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              content,
              style: const TextStyle(fontSize: 16.0, height: 1.5),
            ),
            const SizedBox(height: 32.0),
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
