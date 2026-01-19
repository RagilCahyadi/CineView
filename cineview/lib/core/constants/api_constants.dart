class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String storageUrl = 'http://10.0.2.2:8000/storage';

  // Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';

  // Watchlist
  static const String watchlist = '/watchlist';
  static const String watchlistCheck = '/watchlist/check';

  // Reviews
  static const String reviews = '/reviews';
  static const String reviewsByMovie = '/reviews/movie';

  // Profile
  static const String profile = '/user';
  static const String updateProfile = '/user/update';
  static const String changePassword = '/user/change-password';
}
