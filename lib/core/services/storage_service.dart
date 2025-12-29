import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadReceiptImage({
    required String userId,
    required String vehicleId,
    required String logId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('receipts').child(userId).child(vehicleId).child('$logId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Resim yüklenirken hata oluştu: $e');
    }
  }

  Future<void> deleteReceiptImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Resim silinirken hata oluştu: $e');
    }
  }
}