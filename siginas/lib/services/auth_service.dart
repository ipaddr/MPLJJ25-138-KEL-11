// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk memantau perubahan status autentikasi pengguna
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mendapatkan pengguna yang sedang login
  User? get currentUser => _auth.currentUser;

  // --- Fungsi Registrasi Pengguna Baru (Role 'school') ---
  Future<String?> registerUser({
    required String schoolName,
    required String address,
    required String npsn,
    // HAPUS parameter totalStudents dari sini karena akan diinisialisasi ke 0
    // required int totalStudents,
    required String email,
    required String password,
  }) async {
    print('DEBUG (AuthService): Memulai registrasi untuk email: $email');
    try {
      // 1. Buat pengguna baru dengan email dan password di Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Pastikan user tidak null setelah registrasi
      if (userCredential.user == null) {
        print(
            'DEBUG (AuthService): Gagal membuat pengguna, userCredential.user adalah null.');
        return 'Gagal membuat pengguna. Silakan coba lagi.';
      }

      print(
          'DEBUG (AuthService): Pengguna Auth dibuat. UID: ${userCredential.user!.uid}');

      // 2. Simpan data tambahan pengguna (profil sekolah) di Firestore
      // UID dari Firebase Auth akan menjadi Document ID di koleksi 'users'
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid, // Simpan UID juga di dokumen
        'nama_sekolah': schoolName,
        'alamat': address,
        'npsn': npsn,
        'jumlah_siswa': 0, // <<< DISET KE 0 SECARA DEFAULT SAAT REGISTRASI
        'email': email,
        'role': 'school',
        'is_verified': false,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'profile_image_url': null,
        // <<< TAMBAHKAN FIELD-FIELD INI UNTUK STATUS LAPORAN AWAL >>>
        'reported_students_today': 0,
        'school_has_completed_daily_report': false,
        // 'last_daily_report_submitted_at': null, // Opsional: jika perlu timestamp awal
      });

      print('DEBUG (AuthService): Dokumen pengguna Firestore berhasil dibuat.');
      return null; // Mengembalikan null menandakan registrasi berhasil
    } on FirebaseAuthException catch (e) {
      print(
          'DEBUG (AuthService): Registrasi GAGAL (FirebaseAuthException). Code: ${e.code}, Message: ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email sudah digunakan oleh akun lain. Silakan gunakan email yang berbeda.';
        case 'weak-password':
          return 'Password terlalu lemah. Password harus setidaknya 6 karakter.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'operation-not-allowed':
          return 'Registrasi dengan email/password tidak diaktifkan. Hubungi admin.';
        default:
          return 'Terjadi kesalahan autentikasi: ${e.message}. Kode: ${e.code}';
      }
    } catch (e) {
      print('DEBUG (AuthService): Terjadi kesalahan tidak terduga: $e');
      return 'Terjadi kesalahan tidak terduga: $e';
    }
  }

  // --- Fungsi Login Pengguna ---
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    print('DEBUG (AuthService): Memulai proses signIn untuk email: $email');
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(
          'DEBUG (AuthService): signIn BERHASIL. UID: ${userCredential.user?.uid}');
      return null; // Mengembalikan null menandakan login berhasil
    } on FirebaseAuthException catch (e) {
      print(
          'DEBUG (AuthService): signIn GAGAL (FirebaseAuthException). Code: ${e.code}, Message: ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          return 'Pengguna tidak ditemukan untuk email tersebut.';
        case 'wrong-password':
          return 'Password salah. Silakan coba lagi.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'user-disabled':
          return 'Akun pengguna ini telah dinonaktifkan.';
        case 'network-request-failed':
          return 'Tidak ada koneksi internet. Silakan periksa koneksi Anda.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan login. Silakan coba lagi nanti.';
        case 'operation-not-allowed':
          return 'Login dengan email/password tidak diaktifkan. Hubungi admin.';
        default:
          return 'Terjadi kesalahan login: ${e.message}. Kode: ${e.code}';
      }
    } catch (e) {
      print('DEBUG (AuthService): signIn GAGAL (Error Umum). Error: $e');
      return 'Terjadi kesalahan tidak terduga: $e';
    }
  }

  // --- Fungsi Logout Pengguna ---
  Future<void> signOut() async {
    print('DEBUG (AuthService): Memulai proses signOut...');
    try {
      await _auth.signOut();
      print('DEBUG (AuthService): signOut BERHASIL.');
    } catch (e) {
      print('DEBUG (AuthService): signOut GAGAL dengan error: $e');
    }
  }

  // --- Fungsi untuk Mendapatkan Role Pengguna dari Firestore ---
  Future<String?> getUserRole(String uid) async {
    print('DEBUG (AuthService): Mengambil role untuk UID: $uid');
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (userDoc.exists) {
        final role = userDoc.get('role') as String?;
        print('DEBUG (AuthService): Role ditemukan: $role');
        return role;
      }
      print(
          'DEBUG (AuthService): Dokumen pengguna TIDAK ditemukan untuk UID: $uid');
      return null;
    } on FirebaseException catch (e) {
      print(
          'DEBUG (AuthService): FirebaseException saat mengambil role: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('DEBUG (AuthService): Error umum saat mengambil role pengguna: $e');
      return null;
    }
  }

  // --- Fungsi untuk Mendapatkan Detail Pengguna dari Firestore ---
  Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    print('DEBUG (AuthService): Mengambil detail pengguna untuk UID: $uid');
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        print('DEBUG (AuthService): Detail pengguna ditemukan.');
        return data;
      }
      print(
          'DEBUG (AuthService): Dokumen detail pengguna TIDAK ditemukan untuk UID: $uid');
      return null;
    } on FirebaseException catch (e) {
      print(
          'DEBUG (AuthService): FirebaseException saat mengambil detail: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print(
          'DEBUG (AuthService): Error umum saat mengambil detail pengguna: $e');
      return null;
    }
  }
}
