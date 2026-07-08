import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPdfReport({
    required String topic,
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      final sanitizedTopic = topic.replaceAll(RegExp(r'[^\w\s\-]'), '').replaceAll(' ', '_').toLowerCase();
      final path = 'reports/${sanitizedTopic}_$fileName';
      final ref = _storage.ref().child(path);

      // Specify metadata
      final metadata = SettableMetadata(
        contentType: 'application/pdf',
        contentDisposition: 'attachment; filename="$fileName"',
        customMetadata: {
          'topic': topic,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putData(pdfBytes, metadata);
      final snapshot = await uploadTask;
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload PDF report: $e');
    }
  }
}
