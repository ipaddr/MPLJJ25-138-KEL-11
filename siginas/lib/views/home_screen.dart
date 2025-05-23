import 'package:flutter/material.dart';
import 'package:siginas/views/all_pending_registration.dart';
import 'package:siginas/views/article_screen.dart';
import 'package:siginas/views/chatbot/chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Contoh data lengkap pendaftaran tertunda
    final List<Map<String, dynamic>> _allPendingRegistrations = [
      {
        'namaSekolah': 'SD Negeri 1 Jakarta',
        'alamat': 'Jakarta Pusat',
        'jumlahSiswa': 300,
        'email': 'sdn1@jakarta.go.id',
        'npsn': '10101010'
      },
      {
        'namaSekolah': 'SMP Negeri 3 Surabaya',
        'alamat': 'Surabaya Timur',
        'jumlahSiswa': 450,
        'email': 'smpn3@surabaya.go.id',
        'npsn': '20202020'
      },
      {
        'namaSekolah': 'SD Negeri 5 Bandung',
        'alamat': 'Bandung Barat',
        'jumlahSiswa': 350,
        'email': 'sdn5@bandung.go.id',
        'npsn': '10303030'
      },
      {
        'namaSekolah': 'SMA Negeri 2 Yogyakarta',
        'alamat': 'Yogyakarta Kota',
        'jumlahSiswa': 500,
        'email': 'sman2@yogyakarta.go.id',
        'npsn': '30404040'
      },
      // ... tambahkan data lainnya
    ];

    final List<Map<String, dynamic>> _limitedPendingRegistrations =
        _allPendingRegistrations.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SiGiNas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Chatbot',
            onPressed: () {
              // Navigasi ke ChatBotScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatBotScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Laporan Nasional',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildMonthlyRecipientChart(),
            if (widget.role == 'admin') ...[
              const SizedBox(height: 24.0),
              // _buildTotalInfoCard(), // Anda bisa menambahkan ini jika diperlukan
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pendaftaran Tertunda',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigasi ke AllPendingRegistrationsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllPendingRegistrationsScreen(
                            allPendingRegistrations: _allPendingRegistrations,
                          ),
                        ),
                      );
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              _buildLimitedPendingRegistrations(_limitedPendingRegistrations),
            ],
            const SizedBox(height: 24.0),
            const Text(
              'Artikel Gizi Terbaru',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildNutritionalArticleList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyRecipientChart() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Text('Chart Visualization'),
      ),
    );
  }

  Widget _buildLimitedPendingRegistrations(
      List<Map<String, dynamic>> registrations) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: registrations.length,
      itemBuilder: (context, index) {
        final registration = registrations[index];
        return ListTile(
          title: Text(registration['namaSekolah'] ?? 'Nama Sekolah'),
          subtitle: Text(registration['alamat'] ?? 'Alamat belum tersedia'),
        );
      },
    );
  }

  Widget _buildNutritionalArticleList(BuildContext context) {
    final List<ArticleData> articles = [
      ArticleData(
        title: 'Panduan Gizi Seimbang untuk Anak Sekolah',
        timeAgo: '2 jam yang lalu',
        content: 'Isi lengkap artikel panduan gizi seimbang...',
      ),
      ArticleData(
        title: 'Tips Menyiapkan Bekal Sehat',
        timeAgo: '5 jam yang lalu',
        content: 'Berbagai tips praktis untuk menyiapkan bekal sehat...',
      ),
    ];

    return Column(
      children: articles
          .map((article) => _buildArticleItem(article, context))
          .toList(),
    );
  }

  Widget _buildArticleItem(ArticleData article, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleScreen(
              title: article.title,
              authorDate: 'Tanggal Artikel',
              readTime: 'Waktu Baca',
              content: article.content,
            ),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: const Center(child: Text('Article Image')),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(article.timeAgo, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArticleData {
  final String title;
  final String timeAgo;
  final String content;

  ArticleData({
    required this.title,
    required this.timeAgo,
    required this.content,
  });
}
