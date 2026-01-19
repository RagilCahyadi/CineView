class MovieModel {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final List<int> genreIds;
  final double popularity;
  final bool adult;
  final double voteAverage;
  final int? runtime;
  final String? certification;

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.genreIds,
    required this.popularity,
    required this.adult,
    required this.voteAverage,
    this.runtime,
    this.certification,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? json['first_air_date'],
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      popularity: (json['popularity'] ?? 0).toDouble(),
      adult: json['adult'] ?? false,
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      runtime: json['runtime'],
      certification: json['certification'],
    );
  }

  String get year => releaseDate?.split('-').first ?? '';

  String get ageRating => certification ?? (adult ? '18+' : 'NR');

  String get durationDisplay {
    if (runtime == null) return '';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}
