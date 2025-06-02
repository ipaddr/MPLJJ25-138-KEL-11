import 'package:flutter/material.dart';
import 'package:siginas/services/auth_service.dart'; // Import AuthService
// import 'package:siginas/views/auth/register_screen.dart'; // Import RegisterScreen
import 'package:siginas/views/main_app_navigator.dart'; // Import MainAppNavigator

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
  bool _isLoading = false; // State untuk indikator loading

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Tampilkan loading
      });

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      String? errorMessage = await AuthService().signIn(
        email: email,
        password: password,
      );

      // Pastikan _isLoading mati sebelum menampilkan dialog error atau navigasi
      setState(() {
        _isLoading = false;
      });

      if (errorMessage == null) {
        // Login berhasil. Ambil role pengguna dari Firestore.
        print(
            'DEBUG (LoginScreen): Login berhasil. Mengambil role pengguna...');
        String? userRole =
            await AuthService().getUserRole(AuthService().currentUser!.uid);

        if (userRole != null) {
          print(
              'DEBUG (LoginScreen): Role didapat: $userRole. Mengarahkan ke MainAppNavigator.');
          // Arahkan secara paksa ke MainAppNavigator dengan role yang benar
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MainAppNavigator(
                  role: userRole), // Teruskan role yang didapat
            ),
            (Route<dynamic> route) => false, // Menghapus semua route sebelumnya
          );
        } else {
          // Kasus aneh: login berhasil tapi role tidak ditemukan di Firestore
          print(
              'DEBUG (LoginScreen): Login berhasil tapi role tidak ditemukan. Logout paksa.');
          await AuthService().signOut(); // Logout untuk membersihkan sesi
          _showErrorDialog(
              'Login berhasil, tapi data role tidak ditemukan. Silakan coba lagi atau hubungi admin.');
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
