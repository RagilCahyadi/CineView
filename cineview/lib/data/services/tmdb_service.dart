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

  Future<Map> getMovieReleaseDates(int movieId) async {
    final response = await _tmdb.v3.movies.getDetails(
      movieId,
      appendToResponse: 'release_dates',
    );
    return response;
  }

  Future<Map<String, dynamic>> getMovieWithDetails(
    int movieId, {
    String countryCode = 'US',
  }) async {
    try {
      final details = await _tmdb.v3.movies.getDetails(
        movieId,
        appendToResponse: 'release_dates',
      );

      String? certification;
      final releaseDates = details['release_dates']?['results'] as List?;

      if (releaseDates != null) {
        for (var country in releaseDates) {
          if (country['iso_3166_1'] == countryCode ||
              country['iso_3166_1'] == 'US') {
            final releases = country['release_dates'] as List?;
            if (releases != null && releases.isNotEmpty) {
              for (var release in releases) {
                if (release['certification'] != null &&
                    release['certification'].toString().isNotEmpty) {
                  certification = release['certification'];
                  break;
                }
              }
            }
            if (certification != null && country['iso_3166_1'] == countryCode) {
              break;
            }
          }
        }
      }

      details['certification'] = certification;

      return Map<String, dynamic>.from(details);
    } catch (e) {
      return {};
    }
  }

  Future<Map> getSimilarMovies(int movieId, {int page = 1}) async {
    return await _tmdb.v3.movies.getSimilar(movieId, page: page);
  }

  Future<Map> searchMovies({required String query, int page = 1}) async {
    return await _tmdb.v3.search.queryMovies(query, page: page);
  }

  Future<Map> searchPeople(String query, {int page = 1}) async {
    return await _tmdb.v3.search.queryPeople(query, page: page);
  }

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

  Future<List<Map<String, dynamic>>> getHotTrailers({int limit = 5}) async {
    try {
      final trending = await getTrendingMovies();
      List<Map<String, dynamic>> trailers = [];

      final results = trending['results'] as List? ?? [];

      for (int i = 0; i < results.length && trailers.length < limit; i++) {
        try {
          final movieId = results[i]['id'];
          final videos = await getMovieVideos(movieId);
          final videoList = videos['results'] as List? ?? [];

          Map<String, dynamic>? trailer;
          for (var v in videoList) {
            if (v['type'] == 'Trailer' && v['site'] == 'YouTube') {
              trailer = v;
              break;
            }
          }

          if (trailer != null) {
            trailers.add({
              'movie': results[i],
              'trailer': trailer,
              'youtube_url':
                  'https://www.youtube.com/watch?v=${trailer['key']}',
              'thumbnail':
                  'https://img.youtube.com/vi/${trailer['key']}/hqdefault.jpg',
            });
          }
        } catch (e) {
          continue;
        }
      }

      return trailers;
    } catch (e) {
      return [];
    }
  }
}
