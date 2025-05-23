import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:siginas/services/auth_service.dart'; // Import AuthService Anda
import 'package:siginas/views/auth/login_screen.dart';
import 'package:siginas/views/auth/register_screen.dart';
import 'package:siginas/views/main_app_navigator.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // AuthWrapper akan menangani navigasi awal berdasarkan status autentikasi
      home:
          const AuthWrapper(), // Pastikan ini tidak const jika AuthWrapper bukan const
      routes: {
        '/register': (context) => const RegisterScreen(),
        // Anda mungkin perlu menambahkan rute lain yang diakses via Navigator.pushNamed
        // E.g., jika Anda memiliki tombol 'Kembali ke Login' di RegisterScreen
        // '/login': (context) => const LoginScreen(),
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
        // ... (logging dan penanganan loading/error seperti sebelumnya)

        final User? user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        } else {
          return FutureBuilder<String?>(
            future: AuthService().getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              // ... (logging dan penanganan loading/error seperti sebelumnya)

              if (roleSnapshot.hasError || roleSnapshot.data == null) {
                // AuthService().signOut();
                return const LoginScreen();
              }

              final String userRole = roleSnapshot.data!;
              // Mengembalikan MainAppNavigator dengan role
              return MainAppNavigator(role: userRole);
            },
          );
        }
      },
    );
  }
}
