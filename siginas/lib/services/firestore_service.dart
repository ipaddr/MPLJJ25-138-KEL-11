// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Operasi Users/Schools (Profil Pengguna) ---
  // Mendapatkan stream detail profil sekolah (untuk ProfileScreen)
  Stream<Map<String, dynamic>?> streamUserProfile(String uid) {
    print('DEBUG (FirestoreService): Streaming user profile for UID: $uid');
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        print(
            'DEBUG (FirestoreService): User profile snapshot received for UID: $uid');
        return snapshot.data() as Map<String, dynamic>?;
      }
      print(
          'DEBUG (FirestoreService): User profile document does not exist for UID: $uid');
      return null;
    });
  }

  // Memperbarui profil sekolah
  Future<String?> updateSchoolProfile(
      String uid, Map<String, dynamic> data) async {
    print(
        'DEBUG (FirestoreService): Updating user profile for UID: $uid with data: $data');
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updated_at':
            FieldValue.serverTimestamp(), // Tambahkan timestamp update
      });
      print(
          'DEBUG (FirestoreService): User profile updated successfully for UID: $uid');
      return null; // Sukses
    } on FirebaseException catch (e) {
      print(
          'DEBUG (FirestoreService): FirebaseException updating profile: ${e.code} - ${e.message}');
      return e.message;
    } catch (e) {
      print('DEBUG (FirestoreService): Error updating profile: $e');
      return e.toString();
    }
  }

  // --- Operasi Artikel ---
  // Mendapatkan stream artikel (untuk HomeScreen)
  Stream<List<Map<String, dynamic>>> streamArticles() {
    print('DEBUG (FirestoreService): Streaming articles...');
    return _firestore
        .collection('articles')
        .orderBy('publish_date', descending: true)
        .snapshots()
        .map((snapshot) {
      print(
          'DEBUG (FirestoreService): Articles snapshot received. Count: ${snapshot.docs.length}');
      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id // Sertakan ID dokumen jika diperlukan
              })
          .toList();
    });
  }

  // --- Operasi Siswa (Subcollection) ---
  // Mendapatkan stream daftar siswa untuk sekolah tertentu
  Stream<List<Map<String, dynamic>>> streamStudents(String schoolUid) {
    print(
        'DEBUG (FirestoreService): Streaming students for School UID: $schoolUid');
    return _firestore
        .collection('users') // Koleksi induk sekolah
        .doc(schoolUid)
        .collection('students') // Subkoleksi siswa
        .orderBy('nama')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id // Sertakan ID dokumen siswa
                })
            .toList());
  }

  // Menambahkan siswa baru
  Future<String?> addStudent(
      String schoolUid, Map<String, dynamic> studentData) async {
    print(
        'DEBUG (FirestoreService): Adding student for School UID: $schoolUid with data: $studentData');
    try {
      await _firestore
          .collection('users')
          .doc(schoolUid)
          .collection('students')
          .add({
        ...studentData,
        'registered_at': FieldValue.serverTimestamp(),
      });
      print('DEBUG (FirestoreService): Student added successfully.');
      return null;
    } on FirebaseException catch (e) {
      print(
          'DEBUG (FirestoreService): FirebaseException adding student: ${e.code} - ${e.message}');
      return e.message;
    } catch (e) {
      print('DEBUG (FirestoreService): Error adding student: $e');
      return e.toString();
    }
  }

  // --- Operasi Laporan Harian (Subcollection) ---
  // Menambahkan laporan harian untuk siswa
  Future<String?> addDailyReport(String schoolUid, String studentId,
      Map<String, dynamic> reportData) async {
    print(
        'DEBUG (FirestoreService): Adding daily report for student: $studentId in school: $schoolUid with data: $reportData');
    try {
      // Menggunakan set dengan ID dokumen unik (misalnya timestamp) atau add()
      await _firestore
          .collection('users')
          .doc(schoolUid)
          .collection('students')
          .doc(studentId)
          .collection('daily_reports')
          .doc(DateTime.now()
              .toIso8601String()
              .split('T')[0]) // ID Dokumen: Tanggal YYYY-MM-DD
          .set({
        ...reportData,
        'uploaded_at': FieldValue.serverTimestamp(),
      });
      print('DEBUG (FirestoreService): Daily report added successfully.');
      return null;
    } on FirebaseException catch (e) {
      print(
          'DEBUG (FirestoreService): FirebaseException adding daily report: ${e.code} - ${e.message}');
      return e.message;
    } catch (e) {
      print('DEBUG (FirestoreService): Error adding daily report: $e');
      return e.toString();
    }
  }

  // --- Operasi Admin (Pendaftaran Tertunda) ---
  // Mendapatkan stream pendaftaran sekolah yang statusnya 'pending'
  Stream<List<Map<String, dynamic>>> streamPendingRegistrations() {
    print('DEBUG (FirestoreService): Streaming pending registrations...');
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'school')
        .where('is_verified', isEqualTo: false)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'uid': doc.id})
            .toList()); // Sertakan UID dokumen
  }

  // Memperbarui status verifikasi sekolah (oleh admin)
  Future<String?> updateSchoolVerificationStatus(
      String schoolUid, bool isVerified) async {
    print(
        'DEBUG (FirestoreService): Updating verification status for School UID: $schoolUid to is_verified: $isVerified');
    try {
      await _firestore.collection('users').doc(schoolUid).update({
        'is_verified': isVerified,
        'updated_at': FieldValue.serverTimestamp(),
      });
      print(
          'DEBUG (FirestoreService): Verification status updated successfully.');
      return null;
    } on FirebaseException catch (e) {
      print(
          'DEBUG (FirestoreService): FirebaseException updating verification status: ${e.code} - ${e.message}');
      return e.message;
    } catch (e) {
      print('DEBUG (FirestoreService): Error updating verification status: $e');
      return e.toString();
    }
  }

  // --- Operasi Statistik Nasional (Admin) ---
  // Mendapatkan stream statistik nasional (jika di-update oleh Cloud Functions)
  Stream<Map<String, dynamic>?> streamNationalStats() {
    print('DEBUG (FirestoreService): Streaming national stats...');
    return _firestore
        .collection('national_stats')
        .doc('Gl14eP7zjqub64AAhWfR')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      }
      print(
          'DEBUG (FirestoreService): National stats document (summary) does not exist.');
      return null;
    });
  }

  // --- Operasi Laporan Admin (Daftar Sekolah Belum Lapor Harian) ---
  // Mendapatkan stream daftar sekolah yang belum melaporkan hari ini
  // Filter: role 'school', is_verified true, has_reported_today false
  Stream<List<Map<String, dynamic>>> streamUnreportedSchoolsToday() {
    print(
        'DEBUG (FirestoreService): Streaming unreported schools for today...');
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'school')
        .where('is_verified',
            isEqualTo: true) // Hanya sekolah yang diverifikasi
        // >>> KOREKSI DI SINI: Gunakan field school_has_completed_daily_report <<<
        .where('school_has_completed_daily_report',
            isEqualTo: false) // Belum lapor semua siswa
        // >>> Tambahkan orderBy jika Anda ingin mengurutkan hasilnya <<<
        // .orderBy('nama_sekolah')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'uid': doc.id // Sertakan UID dokumen
                })
            .toList());
  }

  // --- Operasi Laporan Admin (Filter Tabel Sekolah) ---
  // Mendapatkan stream daftar sekolah berdasarkan filter
  Stream<List<Map<String, dynamic>>> streamFilteredSchools({
    String? provinsi,
    String? kota,
    String? jenjang,
    // DateTime? tanggal, // Jika nanti ingin filter berdasarkan laporan pada tanggal tertentu
  }) {
    Query query = _firestore.collection('users'); // Mulai dari koleksi users

    // Filter berdasarkan role 'school' dan sudah diverifikasi
    query = query
        .where('role', isEqualTo: 'school')
        .where('is_verified', isEqualTo: true);

    if (provinsi != null && provinsi.isNotEmpty) {
      query = query.where('provinsi', isEqualTo: provinsi);
    }
    if (kota != null && kota.isNotEmpty) {
      query = query.where('kota', isEqualTo: kota);
    }
    if (jenjang != null && jenjang.isNotEmpty) {
      query = query.where('jenjang', isEqualTo: jenjang);
    }
    // Jika ingin filter berdasarkan tanggal laporan, ini akan lebih kompleks
    // karena melibatkan subkoleksi daily_reports dan mungkin Cloud Functions.

    print(
        'DEBUG (FirestoreService): Streaming filtered schools with: Provinsi: $provinsi, Kota: $kota, Jenjang: $jenjang');

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) {
          final data = doc.data()
              as Map<String, dynamic>?; // Ambil data sebagai Map nullable

          if (data == null) {
            return <String,
                dynamic>{}; // Kembalikan map kosong dengan tipe eksplisit
          }

          // KOREKSI UTAMA DI SINI: Pastikan map yang dikembalikan bertipe Map<String, dynamic>
          return {
            ...data, // Gunakan spread operator yang aman
            'uid': doc.id // Tambahkan UID dokumen
          } as Map<String,
              dynamic>; // <<< Lakukan cast eksplisit untuk map yang dihasilkan
        })
        .where((data) => data.isNotEmpty)
        .toList()); // Filter out empty maps if any
  }
}
