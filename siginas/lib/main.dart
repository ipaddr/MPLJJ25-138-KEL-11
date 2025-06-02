import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siginas/services/auth_service.dart';
import 'package:siginas/views/auth/login_screen.dart';
import 'package:siginas/views/auth/register_screen.dart';
import 'package:siginas/views/main_app_navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // --- AKTIFKAN OFFLINE PERSISTENCE FIRESTORE DI SINI ---
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes:
        40 * 1024 * 1024, // Opsional: Atur ukuran cache, misalnya 40 MB
    // Default adalah 100MB. HATI-HATI dengan UNLIMITED di produksi!
  );
  print('DEBUG: Firestore offline persistence diaktifkan.');
  // --- END AKTIVASI ---

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiGiNas',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const AuthWrapper(),
      routes: {
        // Definisikan rute yang mungkin diakses melalui Navigator.pushNamed
        '/register': (context) => const RegisterScreen(),
        // '/login': (context) => const LoginScreen(), // Tidak diperlukan jika AuthWrapper adalah home
      },
    );
  }
}

// Widget pembungkus untuk menangani logika autentikasi
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Stream<User?> _authStateChangesStream;

  @override
  void initState() {
    super.initState();
    _authStateChangesStream = AuthService().authStateChanges;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStateChangesStream,
      builder: (context, snapshot) {
        // --- LOG UNTUK DEBUGGING AUTH WRAPPER ---
        print(
            'DEBUG (AuthWrapper): Status StreamBuilder - ConnectionState: ${snapshot.connectionState}, HasData: ${snapshot.hasData}, User UID: ${snapshot.data?.uid}');
        // --- END LOG ---

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan indikator loading saat menunggu status autentikasi
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          // Tangani error jika terjadi
          print(
              'DEBUG (AuthWrapper): Error authStateChanges: ${snapshot.error}');
          return const Scaffold(
            body: Center(
              child: Text('Terjadi kesalahan autentikasi. Silakan coba lagi.'),
            ),
          );
        }

        final User? user = snapshot.data;

        if (user == null) {
          // Jika pengguna tidak login, arahkan ke halaman login
          print(
              'DEBUG (AuthWrapper): User is NULL. Mengarahkan ke LoginScreen.');
          return const LoginScreen();
        } else {
          // Jika pengguna sudah login, ambil role mereka dari Firestore
          print(
              'DEBUG (AuthWrapper): User is ${user.uid}. Mengambil role dari Firestore...');
          return FutureBuilder<String?>(
            future: AuthService().getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              // --- LOG UNTUK DEBUGGING FUTUREBUILDER ROLE ---
              print(
                  'DEBUG (AuthWrapper - RoleFB): Status FutureBuilder - ConnectionState: ${roleSnapshot.connectionState}, HasData: ${roleSnapshot.hasData}, Role: ${roleSnapshot.data}');
              // --- END LOG ---

              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                // Tampilkan indikator loading saat menunggu role
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (roleSnapshot.hasError || roleSnapshot.data == null) {
                // Tangani error jika role tidak ditemukan atau ada masalah
                print(
                    'DEBUG (AuthWrapper - RoleFB): Role tidak ditemukan atau ada error saat mengambil role: ${roleSnapshot.error}. ');
                print(
                    'DEBUG (AuthWrapper - RoleFB): Tidak melakukan signOut paksa di sini. Mungkin karena latensi Firestore atau dokumen belum lengkap.');
                return const LoginScreen();
              }

              final String userRole = roleSnapshot.data!;
              print(
                  'DEBUG (AuthWrapper): Role didapat: $userRole. Mengarahkan ke MainAppNavigator.');
              return MainAppNavigator(role: userRole);
            },
          );
        }
      },
    );
  }
}
