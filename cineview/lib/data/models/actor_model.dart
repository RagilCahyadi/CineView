class ActorModel {
  final int id;
  final String name;
  final String? profilePath;
  final String? knownForDepartment;
  final double popularity;
  final int gender;
  final List<dynamic> knownFor;

  ActorModel({
    required this.id,
    required this.name,
    this.profilePath,
    this.knownForDepartment,
    required this.popularity,
    required this.gender,
    required this.knownFor,
  });

  factory ActorModel.fromJson(Map<String, dynamic> json) {
    return ActorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePath: json['profile_path'],
      knownForDepartment: json['known_for_department'],
      popularity: (json['popularity'] ?? 0).toDouble(),
      gender: json['gender'] ?? 0,
      knownFor: json['known_for'] ?? [],
    );
  }

  String get genderDisplay =>
      gender == 1 ? 'Female' : (gender == 2 ? 'Male' : 'Unknown');
}
