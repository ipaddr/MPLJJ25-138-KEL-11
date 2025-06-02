import 'package:flutter/material.dart';
import 'package:siginas/services/firestore_service.dart';
import 'package:siginas/services/auth_service.dart';
import 'package:siginas/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Tambahkan import ini

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  late TextEditingController _schoolNameController;
  late TextEditingController _addressController;
  late TextEditingController _npsnController;
  late TextEditingController _totalStudentsController;
  late TextEditingController _emailController;
  late TextEditingController _tahunAkreditasiController;

  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _schoolNameController =
        TextEditingController(text: widget.userData['nama_sekolah'] ?? '');
    _addressController =
        TextEditingController(text: widget.userData['alamat'] ?? '');
    _npsnController =
        TextEditingController(text: widget.userData['npsn'] ?? '');
    _totalStudentsController = TextEditingController(
        text: (widget.userData['jumlah_siswa'] ?? 0).toString());
    _emailController =
        TextEditingController(text: widget.userData['email'] ?? '');
    _tahunAkreditasiController = TextEditingController(
        text: (widget.userData['tahun_akreditasi'] ?? 0).toString());
  }

  // Fungsi untuk memilih gambar dari galeri atau kamera
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

    if (image != null) {
      File? finalImageFile;

      if (await image.length() > 1000 * 1024) {
        print(
            'DEBUG (EditProfile): Ukuran gambar besar (${(await image.length() / (1024 * 1024)).toStringAsFixed(2)} MB), melakukan kompresi...');
        XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
          image.path,
          '${image.path}_compressed.jpg',
          minWidth: 800,
          minHeight: 800,
          quality: 70,
        );
        finalImageFile =
            compressedXFile != null ? File(compressedXFile.path) : null;
        print(
            'DEBUG (EditProfile): Kompresi selesai. Ukuran baru: ${((finalImageFile?.lengthSync() ?? 0) / 1024).toStringAsFixed(2)} KB');
      } else {
        finalImageFile = File(image.path);
      }

      setState(() {
        _pickedImage = finalImageFile;
      });
      print(
          'DEBUG (EditProfile): Gambar dipilih dan diproses: ${_pickedImage?.path}');
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String? currentUserId = AuthService().currentUser?.uid;
      if (currentUserId == null) {
        _showSnackBar('Pengguna tidak terautentikasi.', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String? profileImageUrl =
          widget.userData['profile_image_url'] as String?; // URL gambar lama

      // Jika ada gambar baru yang dipilih, unggah dulu ke Storage
      if (_pickedImage != null) {
        print('DEBUG (EditProfile): Mengunggah gambar baru...');
        String imagePath =
            'profile_images/$currentUserId/${DateTime.now().millisecondsSinceEpoch}.jpg';
        profileImageUrl =
            await _storageService.uploadImage(_pickedImage!, imagePath);

        if (profileImageUrl == null) {
          _showSnackBar('Gagal mengunggah foto profil.', isError: true);
          setState(() {
            _isLoading = false;
          });
          return;
        }
        print(
            'DEBUG (EditProfile): Foto profil berhasil diunggah. URL: $profileImageUrl');
      }

      // Buat map data yang akan diupdate
      final Map<String, dynamic> updatedData = {
        'nama_sekolah': _schoolNameController.text.trim(),
        'alamat': _addressController.text.trim(),
        'jumlah_siswa': int.tryParse(_totalStudentsController.text.trim()) ?? 0,
        'tahun_akreditasi':
            int.tryParse(_tahunAkreditasiController.text.trim()) ?? 0,
        'profile_image_url':
            profileImageUrl, // Simpan URL gambar (lama atau baru)
      };

      final String? errorMessage = await _firestoreService.updateSchoolProfile(
        currentUserId,
        updatedData,
      );

      // Pastikan widget masih mounted sebelum setState, untuk menghindari error setelah dispose
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (errorMessage == null) {
        _showSnackBar('Profil berhasil diperbarui!');
        Navigator.pop(context);
      } else {
        _showSnackBar('Gagal memperbarui profil: $errorMessage', isError: true);
      }
    }
  }

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
    _tahunAkreditasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!) as ImageProvider
                        : (widget.userData['profile_image_url'] != null &&
                                (widget.userData['profile_image_url'] as String)
                                    .isNotEmpty
                            // KOREKSI DI SINI: Menggunakan CachedNetworkImageProvider
                            ? CachedNetworkImageProvider(
                                    widget.userData['profile_image_url']!)
                                as ImageProvider
                            : null),
                    child: _pickedImage == null &&
                            (widget.userData['profile_image_url'] == null ||
                                (widget.userData['profile_image_url'] as String)
                                    .isEmpty)
                        ? Icon(Icons.camera_alt,
                            size: 40, color: Colors.grey[600])
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              _buildTextField(
                controller: _schoolNameController,
                labelText: 'Nama Sekolah/Instansi',
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama sekolah tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _addressController,
                labelText: 'Alamat',
                maxLines: 2,
                validator: (value) => value == null || value.isEmpty
                    ? 'Alamat tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _npsnController,
                labelText: 'NPSN',
                keyboardType: TextInputType.number,
                readOnly: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'NPSN tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _totalStudentsController,
                labelText: 'Jumlah Murid',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Jumlah murid tidak boleh kosong';
                  if (int.tryParse(value) == null)
                    return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                readOnly: true, // Email dibuat read-only
                validator: (value) => value == null || !value.contains('@')
                    ? 'Masukkan email yang valid'
                    : null,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _tahunAkreditasiController,
                labelText: 'Tahun Akreditasi',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Tahun akreditasi tidak boleh kosong';
                  if (int.tryParse(value) == null)
                    return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18.0),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pembantu untuk membuat TextFormField
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
