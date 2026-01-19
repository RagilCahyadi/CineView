import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/services/auth_service.dart';
import 'package:cineview/data/services/storage_service.dart';
import 'package:cineview/data/services/review_services.dart';
import 'package:cineview/data/services/watchlist_services.dart';
import 'package:cineview/data/services/tmdb_service.dart';
import 'package:cineview/data/models/movie_model.dart';
import 'package:cineview/presentation/screen/settings_page.dart';
import 'package:cineview/presentation/screen/movie_detail_screen.dart';
import 'package:cineview/presentation/screen/edit_profile_page.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final StorageService _storageService = StorageService();

  String _userName = 'Loading...';
  int _watchlistCount = 0;
  int _reviewCount = 0;
  double _averageRating = 0.0;
  bool _isLoading = true;

  List<dynamic> _watchlistItems = [];
  List<dynamic> _userReviews = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Load user data - first try local storage
      var user = await _storageService.getUser();

      // If no local data, try to fetch from API
      if (user == null) {
        final authService = AuthService();
        final result = await authService.getProfile();
        if (result['success'] == true) {
          user = result['user'];
        }
      }

      // Load watchlist
      final watchlistService = WatchlistServices();
      final watchlistResult = await watchlistService.getWatchlist();

      // Load reviews
      final reviewService = ReviewServices();
      final reviewResult = await reviewService.getMyReviews();

      if (mounted) {
        setState(() {
          _userName = user?['name'] ?? 'User';
          _watchlistItems = (watchlistResult['data'] as List?) ?? [];
          _userReviews = (reviewResult['data'] as List?) ?? [];
          _watchlistCount = _watchlistItems.length;
          _reviewCount = _userReviews.length;

          // Calculate average rating
          if (_userReviews.isNotEmpty) {
            double totalRating = 0;
            for (var review in _userReviews) {
              totalRating += (review['rating'] ?? 0).toDouble();
            }
            _averageRating = totalRating / _userReviews.length;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToMovie(int movieId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );

    try {
      final tmdbService = TmdbService();
      final details = await tmdbService.getMovieDetails(movieId);

      if (!mounted) return;
      Navigator.pop(context);

      final movie = MovieModel.fromJson(Map<String, dynamic>.from(details));

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load movie: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
            : RefreshIndicator(
                onRefresh: _loadUserData,
                color: AppTheme.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileHeader(context),
                      const SizedBox(height: 24),
                      _buildStatsSection(),
                      const SizedBox(height: 16),
                      _buildRecentlyViewedSection(),
                      const SizedBox(height: 16),
                      _buildRatingsSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[700]!, width: 2),
                  color: AppTheme.surfaceColor,
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                    if (result == true) {
                      _loadUserData();
                    }
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.backgroundColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                _userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[800]!, width: 1),
            bottom: BorderSide(color: Colors.grey[800]!, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              Icons.star_outline,
              'Ratings',
              '${_averageRating.toStringAsFixed(1)} ($_reviewCount)',
            ),
            Container(width: 1, height: 40, color: Colors.grey[800]),
            _buildStatItem(
              Icons.bookmark_border,
              'Watchlist',
              '$_watchlistCount',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyViewedSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark, color: Colors.grey[400], size: 20),
              const SizedBox(width: 8),
              const Text(
                'My Watchlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _watchlistItems.isEmpty
              ? SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'No movies in watchlist',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              : SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _watchlistItems.length > 5
                        ? 5
                        : _watchlistItems.length,
                    itemBuilder: (context, index) {
                      return _buildWatchlistCard(_watchlistItems[index]);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildWatchlistCard(dynamic item) {
    final String posterPath = item['poster_path'] ?? '';
    final String title = item['movie_title'] ?? 'Unknown';
    final int movieId = item['movie_id'];

    return GestureDetector(
      onTap: () => _navigateToMovie(movieId),
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: posterPath.isNotEmpty
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w200$posterPath',
                      width: 90,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _buildPosterPlaceholder(),
                    )
                  : _buildPosterPlaceholder(),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterPlaceholder() {
    return Container(
      width: 90,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.movie, color: Colors.grey, size: 30),
    );
  }

  Widget _buildRatingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_outline, color: Colors.grey[400], size: 20),
              const SizedBox(width: 8),
              const Text(
                'My Reviews',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _userReviews.isEmpty
              ? SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'No reviews yet',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              : SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _userReviews.length > 5
                        ? 5
                        : _userReviews.length,
                    itemBuilder: (context, index) {
                      return _buildReviewCard(_userReviews[index]);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    final String movieTitle = review['movie_title'] ?? 'Unknown';
    final int rating = review['rating'] ?? 0;
    final int movieId = review['movie_id'];

    return GestureDetector(
      onTap: () => _navigateToMovie(movieId),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movieTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$rating/10',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              review['context'] ?? '',
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
