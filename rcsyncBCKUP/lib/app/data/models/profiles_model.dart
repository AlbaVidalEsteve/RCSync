class ProfileModel {
  final String idProfile;
  final String fullName;
  final String? imageProfile;
  final bool isJunior;
  final String rol;
  final String subcategory;
  final DateTime? createdAt;

  ProfileModel({
    required this.idProfile,
    required this.fullName,
    this.imageProfile,
    this.isJunior = false,
    this.rol = 'piloto',
    this.subcategory = 'STOCK',
    this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      idProfile: json['id_profile'],
      fullName: json['full_name'],
      imageProfile: json['image_profile'],
      isJunior: json['is_junior'] ?? false,
      rol: json['rol'] ?? 'piloto',
      subcategory: json['subcategory'] ?? 'STOCK',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_profile': idProfile,
      'full_name': fullName,
      'image_profile': imageProfile,
      'is_junior': isJunior,
      'rol': rol,
      'subcategory': subcategory,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
