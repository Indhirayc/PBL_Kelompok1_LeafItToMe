import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageSource {
  final FirebaseStorage _storage;

  FirebaseStorageSource({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadLeafImage({
    required String userId,
    required String scanId,
    required String localPath,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw Exception("File gambar tidak ditemukan di path: $localPath");
    }

    final ref = _storage
        .ref()
        .child('scans')
        .child(userId)
        .child('$scanId.jpg');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }
}
