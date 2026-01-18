class CastModel {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;
  final int order;
  final String? knownForDepartement;

  CastModel({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
    required this.order,
    this.knownForDepartement,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'],
      profilePath: json['profile_path'],
      order: json['order'] ?? 0,
      knownForDepartement: json['known_for_department'],
    );
  }
}
