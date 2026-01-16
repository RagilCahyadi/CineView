import 'dart:convert';
import 'dart:io';
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

  // Create a new review with optional photo upload
  Future<Map<String, dynamic>> createReview({
    required int movieId,
    required String movieTitle,
    required int rating,
    required String context,
    required String content,
    File? photoFile,  
  }) async {
    try {
      final token = await _storageService.getToken();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['movie_id'] = movieId.toString();
      request.fields['movie_title'] = movieTitle;
      request.fields['rating'] = rating.toString();
      request.fields['context'] = context;
      request.fields['content'] = content;

      // Add photo file if exists
      if (photoFile != null) {
        var stream = http.ByteStream(photoFile.openRead());
        var length = await photoFile.length();
        var multipartFile = http.MultipartFile(
          'photo',
          stream,
          length,
          filename: photoFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': data['message'] ?? 'You have already reviewed this movie',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create review',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
 
  // Update an existing review with optional photo upload
  Future<Map<String, dynamic>> updateReview({
    required int reviewId,
    int? rating,
    String? context,
    String? content,
    File? photoFile,  
  }) async {
    try {
      final token = await _storageService.getToken();
      
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}/$reviewId'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['_method'] = 'PUT';

      if (rating != null) request.fields['rating'] = rating.toString();
      if (context != null) request.fields['context'] = context;
      if (content != null) request.fields['content'] = content;

      // Add photo file if exists
      if (photoFile != null) {
        var stream = http.ByteStream(photoFile.openRead());
        var length = await photoFile.length();
        var multipartFile = http.MultipartFile(
          'photo',
          stream,
          length,
          filename: photoFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update review',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
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