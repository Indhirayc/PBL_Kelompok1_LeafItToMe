import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String namaLengkap;
  final String email;
  final String noTelepon;
  final String fotoProfil;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.namaLengkap,
    required this.email,
    this.noTelepon = '',
    this.fotoProfil = '',
    this.role = 'user',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'nama_lengkap': namaLengkap,
      'email': email,
      'no_telepon': noTelepon,
      'foto_profil': fotoProfil,
      'role': role,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      namaLengkap: data['nama_lengkap'] ?? '',
      email: data['email'] ?? '',
      noTelepon: data['no_telepon'] ?? '',
      fotoProfil: data['foto_profil'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
