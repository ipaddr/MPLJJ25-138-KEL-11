import 'package:flutter/material.dart';
import 'package:siginas/services/auth_service.dart';
import 'package:siginas/views/main_app_navigator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      String? errorMessage = await AuthService().signIn(
        email: email,
        password: password,
      );

      // Pastikan _isLoading mati sebelum menampilkan dialog error atau navigasi
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (errorMessage == null) {
        // Login berhasil di Firebase Auth. Sekarang, ambil detail pengguna dari Firestore.
        print(
            'DEBUG (LoginScreen): Login berhasil Auth. Mengambil detail pengguna dari Firestore...');

        final String? currentUserId = AuthService().currentUser?.uid;
        if (currentUserId == null) {
          _showErrorDialog(
              'Terjadi kesalahan: UID tidak ditemukan setelah login.');
          return;
        }

        Map<String, dynamic>? userDetails =
            await AuthService().getUserDetails(currentUserId);

        if (!mounted) return; // Penting: cek mounted setelah async call

        if (userDetails != null) {
          final String userRole = userDetails['role'] ?? 'unknown';
          final bool isVerified =
              userDetails['is_verified'] ?? false; // Ambil status is_verified

          print(
              'DEBUG (LoginScreen): Role didapat: $userRole, Is Verified: $isVerified');

          // --- LOGIKA VERIFIKASI ---
          if (userRole == 'school' && !isVerified) {
            // Jika role adalah 'school' dan belum diverifikasi
            print(
                'DEBUG (LoginScreen): Akun sekolah belum diverifikasi. Logout paksa.');
            await AuthService().signOut(); // Logout untuk membersihkan sesi
            if (!mounted) return;
            _showErrorDialog(
                'Akun Anda belum diverifikasi oleh admin. Silakan tunggu atau hubungi admin.');
            return;
          }

          // Jika diverifikasi atau role bukan 'school', lanjutkan ke MainAppNavigator
          print(
              'DEBUG (LoginScreen): Mengarahkan ke MainAppNavigator dengan role: $userRole.');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MainAppNavigator(
                  role: userRole), // Teruskan role yang didapat
            ),
            (Route<dynamic> route) => false, // Menghapus semua route sebelumnya
          );
        } else {
          print(
              'DEBUG (LoginScreen): Login berhasil tapi dokumen profil tidak ditemukan. Logout paksa.');
          await AuthService().signOut(); // Logout untuk membersihkan sesi
          if (!mounted) return;
          _showErrorDialog(
              'Login berhasil, tapi data profil tidak ditemukan. Silakan coba lagi atau hubungi admin.');
        }
      } else {
        // Login gagal. Tampilkan pesan error.
        print('DEBUG (LoginScreen): Login gagal: $errorMessage');
        _showErrorDialog(
            errorMessage); // Panggil fungsi untuk menampilkan dialog error
      }
    }
  }

  // Fungsi untuk menampilkan dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.school_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24.0),
                const Text(
                  'SIGINAS \n Monitoring Makan Bergizi Gratis',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Silakan masuk ke akun Anda',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    } else if (!RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
                        .hasMatch(value)) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    } else if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _login, // Tombol disable saat loading
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: const TextStyle(fontSize: 18.0),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          ) // Indikator loading
                        : const Text('Masuk'),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Belum punya akun?'),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Daftar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '© 2025 SiGiNas. All rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.0, color: Colors.grey),
        ),
      ),
    );
  }
}
