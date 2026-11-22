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

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nama_lengkap': namaLengkap,
      'email': email,
      'no_telepon': noTelepon,
      'foto_profil': fotoProfil,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? 'user-local',
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      email: json['email'] as String? ?? '',
      noTelepon: json['no_telepon'] as String? ?? '',
      fotoProfil: json['foto_profil'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => toJson();
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel.fromJson(map);
}
