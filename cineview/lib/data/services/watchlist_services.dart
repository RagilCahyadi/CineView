import 'dart:convert';
import 'package:cineview/core/constants/api_constants.dart';
import 'package:cineview/data/services/storage_service.dart';
import 'package:http/http.dart' as http;

class WatchlistServices {
  final StorageService _storageService = StorageService();

  // Get all watchlist items for aunthenticated user
  Future<Map<String, dynamic>> getWatchlist() async {
    try {
      final token = await _storageService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.watchlist}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get watchlist',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  //Add a movie to watchlist
  Future<Map<String, dynamic>> addMovieToWatchlist({
    required int movieId,
    required String movieTitle,
    String? posterPath,
  }) async {
    try {
      final token = await _storageService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.watchlist}'),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'movie_id': movieId,
          'movie_title': movieTitle,
          'poster_path': posterPath,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': data['message'] ?? 'Movie already in watchlist',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add movie to watchlist',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Remove a movie from watchlist
  Future<Map<String, dynamic>> removeMovieFromWatchlist(int watchlistId) async {
    try {
      final token = await _storageService.getToken();
      final response = await http.delete(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.watchlist}/$watchlistId',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true, 
          'message': data['message']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to remove movie from watchlist',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Check if a movie is in user watchlist
  Future<Map<String, dynamic>> checkMovieInWatchlist(int movieId) async {
    try {
      final token = await _storageService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.watchlistCheck}/$movieId'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true, 
          'in_watchlist': data['in_watchlist']
        };
      } else {
        return {
          'success': false,
          'in_watchlist': false
        };   
      }
    } catch (e) {
      return {
        'success': false, 
        'in_watchlist': false
      };
    }
  }
}
