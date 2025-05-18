import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:siginas/views/article_screen.dart';
import 'package:siginas/views/auth/login_page.dart';
import 'package:siginas/views/auth/register_page.dart';
import 'package:siginas/views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiGiNas',
      theme: ThemeData(primarySwatch: Colors.red),
      initialRoute: '/', // Halaman awal aplikasi
      routes: {
        '/': (context) => const HomePage(
              role: 'admin',
            ),

        // '/': (context) => const ArticleScreen(
        //       role: 'admin',
        //       title: 'Panduan Gizi Seimbang untuk Anak Sekolah',
        //       authorDate: '2 jam yang lalu',
        //       imageUrl:
        //           'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
        //       readTime: '5 menit baca',
        //       content:
        //           'Gizi yang baik sangat penting untuk pertumbuhan dan perkembangan anak. Berikut adalah 7 cara meningkatkan gizi anak:\n\n'
        //           '1. Berikan makanan bergizi seimbang setiap hari.\n'
        //           '2. Pastikan anak mendapatkan cukup protein, karbohidrat, dan lemak.\n'
        //           '3. Berikan buah-buahan dan sayuran setiap hari.\n'
        //           '4. Batasi makanan olahan dan minuman manis.\n'
        //           '5. Berikan suplemen vitamin dan mineral jika diperlukan.\n'
        //           '6. Ajak anak untuk berolahraga secara teratur.\n'
        //           '7. Konsultasikan dengan dokter atau ahli gizi untuk mendapatkan saran yang lebih spesifik.',
        //     ),
        '/RegisterPage': (context) =>
            const RegisterPage(), // Rute ke halaman register
        '/HomePage': (context) => const HomePage(
              role: 'admin',
            ), // Ganti dengan HomePage() Anda
      },
    );
  }
}
