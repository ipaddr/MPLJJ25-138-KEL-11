import 'package:flutter/material.dart';
import 'package:siginas/services/auth_service.dart'; // Pastikan path ini benar

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _npsnController = TextEditingController();
  final TextEditingController _totalStudentsController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false; // State untuk indikator loading

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Tampilkan loading
      });

      // Pastikan totalStudents adalah angka valid
      final int? totalStudents =
          int.tryParse(_totalStudentsController.text.trim());
      if (totalStudents == null) {
        _showSnackBar('Jumlah murid harus berupa angka valid.', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final String? errorMessage = await _authService.registerUser(
        schoolName: _schoolNameController.text.trim(),
        address: _addressController.text.trim(),
        npsn: _npsnController.text.trim(),
        totalStudents: totalStudents,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false; // Sembunyikan loading
      });

      if (errorMessage == null) {
        _showSnackBar(
          'Registrasi berhasil! Silakan menunggu konfirmasi dari admin.',
          isError: false,
        );
        // Kembali ke halaman login setelah registrasi berhasil
        // Navigator.pop(context) akan kembali ke halaman sebelumnya (LoginScreen)
        Navigator.pop(context);
      } else {
        _showSnackBar(errorMessage, isError: true);
      }
    }
  }

  // Fungsi pembantu untuk menampilkan SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _addressController.dispose();
    _npsnController.dispose();
    _totalStudentsController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Monitoring Makan Siang Gratis',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
              const SizedBox(height: 24.0),
              TextFormField(
                controller: _schoolNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Sekolah/Instansi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama sekolah tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) => value == null || value.isEmpty
                    ? 'Alamat tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _npsnController,
                decoration: const InputDecoration(
                  labelText: 'NPSN',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'NPSN tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _totalStudentsController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Murid',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah murid tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@')
                    ? 'Masukkan email yang valid'
                    : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) => value == null || value.length < 6
                    ? 'Password harus lebih dari 6 karakter'
                    : null,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed:
                    _isLoading ? null : _register, // Disable saat loading
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18.0),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white) // Indikator loading
                    : const Text('Daftar'),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun?'),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () =>
                            Navigator.pop(context), // Kembali ke LoginScreen
                    child: const Text('Masuk'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
