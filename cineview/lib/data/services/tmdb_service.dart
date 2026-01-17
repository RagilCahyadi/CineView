import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tmdb_api/tmdb_api.dart';

class TmdbService {
  final String _apiKey = dotenv.env['TMDB_API_KEY'] ?? "";
  final String _readAccessToken = dotenv.env['TMDB_READ_ACCESS_TOKEN'] ?? "";
  late TMDB _tmdb;

  static const String imageBaseUrl = "https://image.tmdb.org/t/p/";

  TmdbService() {
    _tmdb = TMDB(
      ApiKeys(_apiKey, _readAccessToken),
      logConfig: const ConfigLogger(showLogs: true, showErrorLogs: true),
      defaultLanguage: 'id-ID',
    );
  }

  // ===== IMAGE URLS =====
  static String getPosterUrl(String? posterPath, {String size = 'w500'}) {
    if (posterPath == null || posterPath.isEmpty) return '';
    return '$imageBaseUrl$size$posterPath';
  }

  static String getBackdropUrl(String? backdropPath, {String size = 'w780'}) {
    if (backdropPath == null || backdropPath.isEmpty) return '';
    return '$imageBaseUrl$size$backdropPath';
  }

  static String getProfileUrl(String? profilePath, {String size = 'w185'}) {
    if (profilePath == null || profilePath.isEmpty) return '';
    return '$imageBaseUrl$size$profilePath';
  }

  // ===== MOVIES =====
  Future<Map> getPopularMovies({int page = 1}) async {
    return await _tmdb.v3.movies.getPopular(page: page);
  }

  Future<Map> getNowPlayingMovies({int page = 1}) async {
    return await _tmdb.v3.movies.getNowPlaying(page: page);
  }

  Future<Map> getTopRatedMovies({int page = 1}) async {
    return await _tmdb.v3.movies.getTopRated(page: page);
  }

  Future<Map> getUpcomingMovies({int page = 1}) async {
    return await _tmdb.v3.movies.getUpcoming(page: page);
  }

  Future<Map> getTrendingMovies({
    TimeWindow timeWindow = TimeWindow.week,
  }) async {
    return await _tmdb.v3.trending.getTrending(
      mediaType: MediaType.movie,
      timeWindow: timeWindow,
    );
  }

  Future<Map> getMovieDetails(int movieId) async {
    return await _tmdb.v3.movies.getDetails(movieId);
  }

  Future<Map> getMovieCredits(int movieId) async {
    return await _tmdb.v3.movies.getCredits(movieId);
  }

  Future<Map> getMovieVideos(int movieId) async {
    return await _tmdb.v3.movies.getVideos(movieId);
  }

  Future<Map> getSimilarMovies(int movieId, {int page = 1}) async {
    return await _tmdb.v3.movies.getSimilar(movieId, page: page);
  }

  // ===== SEARCH =====
  Future<Map> searchMovies(String query, {int page = 1}) async {
    return await _tmdb.v3.search.queryMovies(query, page: page);
  }

  Future<Map> searchPeople(String query, {int page = 1}) async {
    return await _tmdb.v3.search.queryPeople(query, page: page);
  }

  // ===== PEOPLE/ACTORS =====
  Future<Map> getPopularPeople({int page = 1}) async {
    return await _tmdb.v3.people.getPopular(page: page);
  }

  Future<Map> getTrendingPeople({
    TimeWindow timeWindow = TimeWindow.week,
  }) async {
    return await _tmdb.v3.trending.getTrending(
      mediaType: MediaType.person,
      timeWindow: timeWindow,
    );
  }

  Future<Map> getPersonDetails(int personId) async {
    return await _tmdb.v3.people.getDetails(personId);
  }

  Future<Map> getPersonMovieCredits(int personId) async {
    return await _tmdb.v3.people.getMovieCredits(personId);
  }

  // ===== HOT TRAILERS =====
  Future<List<Map<String, dynamic>>> getHotTrailers({int limit = 5}) async {
    final trending = await getTrendingMovies();
    List<Map<String, dynamic>> trailers = [];

    final results = trending['results'] as List? ?? [];

    for (
      int i = 0;
      i < (results.length > limit ? limit : results.length);
      i++
    ) {
      final movieId = results[i]['id'];
      final videos = await getMovieVideos(movieId);
      final videoList = videos['results'] as List? ?? [];

      final trailer = videoList.firstWhere(
        (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
        orElse: () => null,
      );

      if (trailer != null) {
        trailers.add({
          'movie': results[i],
          'trailer': trailer,
          'youtube_url': 'https://www.youtube.com/watch?v=${trailer['key']}',
          'thumbnail':
              'https://img.youtube.com/vi/${trailer['key']}/hqdefault.jpg',
        });
      }
    }

    return trailers;
  }
}
