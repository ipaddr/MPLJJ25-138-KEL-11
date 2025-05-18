import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerUser({
    required String schoolName,
    required String address,
    required String npsn,
    required int totalStudents,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'nama_sekolah': schoolName,
        'alamat': address,
        'npsn': npsn,
        'total_students': totalStudents,
        'email': email,
        'role': 'school',
        'created_at': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email sudah digunakan. Gunakan email lain.';
        case 'weak-password':
          return 'Password terlalu lemah. Gunakan password yang lebih kuat.';
        default:
          return 'Terjadi kesalahan. Silakan coba lagi.';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
