import 'package:flutter/material.dart';
import 'package:siginas/views/all_pending_registration.dart';
import 'package:siginas/views/article_screen.dart';
// import 'package:siginas/views/reports/reports_admin.dart';
// import 'package:siginas/views/reports/reports_user.dart';
import 'package:siginas/widgets/navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/HomeScreen');
        break;
      case 1:
        if (widget.role == 'admin') {
          Navigator.pushReplacementNamed(context, '/ReportsAdmin');
        } else {
          Navigator.pushReplacementNamed(context, '/ReportsUser');
        }
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/ProfileScreen');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigasi ke halaman pengaturan
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
            _buildNutritionalArticleList(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        initialIndex: _selectedIndex,
        role: widget.role,
        onItemSelected: _handleNavigation,
        currentIndex: 0,
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

  Widget _buildNutritionalArticleList() {
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
      children: articles.map((article) => _buildArticleItem(article)).toList(),
    );
  }

  Widget _buildArticleItem(ArticleData article) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleScreen(
              title: article.title,
              authorDate: 'Tanggal Artikel', // Ganti dengan data sebenarnya
              readTime: 'Waktu Baca', // Ganti dengan data sebenarnya
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
                child:
                    const Center(child: Text('Article Image')), // Placeholder
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
