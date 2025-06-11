import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:siginas/views/all_pending_registration.dart';
import 'package:siginas/views/article_screen.dart';
import 'package:siginas/views/chatbot/chatbot_screen.dart';
import 'package:siginas/services/firestore_service.dart';
import 'package:siginas/views/registration_details.dart';
import 'package:siginas/widgets/monthly_recipient_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SiGiNas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Chatbot',
            onPressed: () {
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

            // Widget chart yang sudah dipisah ke file baru
            const MonthlyRecipientChart(),

            const SizedBox(height: 24.0),

            if (widget.role == 'admin') ...[
              const SizedBox(height: 24.0),
              _buildPendingRegistrationsSection(context),
              const SizedBox(height: 24.0),
            ],

            const Text(
              'Artikel Gizi Terbaru',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildArticlesFromFirestore(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRegistrationsSection(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().streamPendingRegistrations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(
              'DEBUG (HomeScreen): Error loading pending registrations: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox
              .shrink(); // Sembunyikan jika tidak ada pendaftaran tertunda
        }

        final allPending = snapshot.data!;
        final List<Map<String, dynamic>> limitedPending =
            allPending.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pendaftaran Tertunda',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigasi ke AllPendingRegistrationsScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AllPendingRegistrationsScreen(),
                      ),
                    );
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: limitedPending.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final registration = limitedPending[index];
                return ListTile(
                  title: Text(registration['nama_sekolah'] ??
                      'Nama Sekolah Tidak Tersedia'),
                  subtitle:
                      Text(registration['alamat'] ?? 'Alamat Tidak Tersedia'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigasi ke RegistrationDetailScreen saat item di-tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationDetailScreen(
                          schoolName: registration['nama_sekolah'] ?? '',
                          address: registration['alamat'] ?? '',
                          numberOfStudents: registration['jumlah_siswa'] ?? 0,
                          email: registration['email'] ?? '',
                          npsn: registration['npsn'] ?? '',
                          schoolUid: registration['uid'] ?? '',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildArticlesFromFirestore(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().streamArticles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(
              'DEBUG (HomeScreen): Error loading articles: ${snapshot.error}');
          return Center(child: Text('Gagal memuat artikel: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada artikel yang tersedia.'));
        }

        final articles = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];

            // Format tanggal publikasi
            Timestamp? publishDate = article['publish_date'] as Timestamp?;
            String formattedDate = publishDate != null
                ? '${publishDate.toDate().day} ${[
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'Mei',
                    'Jun',
                    'Jul',
                    'Agu',
                    'Sep',
                    'Okt',
                    'Nov',
                    'Des'
                  ][publishDate.toDate().month - 1]} ${publishDate.toDate().year}'
                : 'Tanggal tidak tersedia';

            // Dapatkan author dari Firestore
            String authorName = article['author'] ?? 'Anonim';

            return _buildArticleItem(
              context: context,
              title: article['title'] ?? 'Judul Tidak Tersedia',
              content: article['content'] ?? 'Konten tidak tersedia',
              imageUrl: article['image_url'] as String?,
              author: authorName,
              formattedPublishDate:
                  formattedDate, // Meneruskan tanggal publikasi yang sudah diformat
            );
          },
        );
      },
    );
  }

  Widget _buildArticleItem({
    required BuildContext context,
    required String title,
    required String content,
    String? imageUrl,
    required String author,
    required String formattedPublishDate,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleScreen(
              title: title,
              author: author,
              formattedPublishDate: formattedPublishDate,
              content: content,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2.0)),
                        errorWidget: (context, url, error) =>
                            const Center(child: Icon(Icons.broken_image)),
                      )
                    : const Center(child: Text('No Image')),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
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
