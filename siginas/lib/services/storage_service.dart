// lib/services/storage_service.dart
import 'dart:io'; // Untuk File
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Mengupload gambar ke Cloud Storage dan mengembalikan URL unduhan
  Future<String?> uploadImage(File imageFile, String path) async {
    print('DEBUG (StorageService): Uploading image to path: $path');
    try {
      final Reference storageRef = _storage.ref().child(path);
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      // Tunggu hingga upload selesai
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      // Dapatkan URL unduhan
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print(
          'DEBUG (StorageService): Image uploaded successfully. URL: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print(
          'DEBUG (StorageService): FirebaseException uploading image: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('DEBUG (StorageService): Error uploading image: $e');
      return null;
    }
  }

  // Contoh path yang disarankan:
  // - 'daily_reports/{SCHOOL_UID}/{STUDENT_ID}/gambar_sebelum_{TIMESTAMP}.jpg'
  // - 'daily_reports/{SCHOOL_UID}/{STUDENT_ID}/gambar_sesudah_{TIMESTAMP}.jpg'
  // - 'article_images/{ARTICLE_ID}/main_image.jpg'
  // - 'profile_images/{USER_UID}.jpg'
}
