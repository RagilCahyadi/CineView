
import 'dart:convert';

import 'package:cineview/core/constants/api_constants.dart';
import 'package:cineview/data/services/storage_service.dart';
import 'package:http/http.dart' as http;

class ReviewServices {
  final StorageService _storageService = StorageService();

  // Get all reviews for authenticated user
  Future<Map<String, dynamic>> getMyReviews() async {
    try{
      final token = await _storageService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      final data = jsonDecode(response.body);

      if(response.statusCode == 200){
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get reviews'
        };
      }
      
    } catch(e){
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  // Get all reviews for a specific movie (public)
  Future<Map<String, dynamic>> getReviewsByMovie (int movieId) async {
    try{
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviewsByMovie}/$movieId'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200){
        return{
          'success': true,
          'data': data['data'],
          'averageRating': data['averageRating'],
          'totalReviews': data['totalReviews'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get reviews'
        };
      }
    } catch (e){
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  // Create a new review 
  Future<Map<String, dynamic>> createReview({
    required int movieId,
    required String movieTitle,
    required int rating,
    required String context,
    required String content,
    String? photoPath,

  }) async{
    try{
      final token = await _storageService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'movie_id': movieId,
          'movie_title': movieTitle,
          'rating': rating,
          'context': context,
          'content': content,
          'photo_path': photoPath,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201){
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else if(response.statusCode == 409){
        return {
          'success': false,
          'message': 'You have already reviewed this movie',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create review',
        };
      }
    } catch(e){
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }
 
  // Update a existing review
  Future<Map<String, dynamic>> updateReview({
    required int reviewId,
    int? rating,
    String? context,
    String? content,
    String? photoPath,
  }) async {
    try {
      final token = await _storageService.getToken();
      
      Map<String, dynamic> body = {};
      if (rating != null) body['rating'] = rating;
      if (context != null) body['context'] = context;
      if (content != null) body['content'] = content;
      if (photoPath != null) body['photo_path'] = photoPath;
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
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
          'message': data['message'] ?? 'Failed to update review',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  //Delete a review
  Future<Map<String, dynamic>> deleteReview(int reviewId) async {
    try{
      final token = await _storageService.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}/$reviewId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200){
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete review',
        };
      }
    } catch (e){
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }
}