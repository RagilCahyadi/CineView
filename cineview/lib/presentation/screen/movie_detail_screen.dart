import 'dart:developer';

import 'package:cineview/data/services/review_services.dart';
import 'package:cineview/presentation/screen/all_reviews_page.dart';
import 'package:cineview/presentation/screen/trailer_player_screen.dart';
import 'package:cineview/presentation/widgets/review_modal.dart';
import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/movie_model.dart';
import 'package:cineview/data/services/tmdb_service.dart';
import 'package:cineview/data/services/watchlist_services.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _hasReviewed = false;
  bool _isCheckingReview = true;
  int? _existingReviewId;

  // Reviews data
  List<dynamic> _movieReviews = [];
  bool _isLoadingReviews = true;
  double _averageRating = 0.0;
  int _totalReviews = 0;
  bool _isInWatchlist = false;
  bool _isCheckingWatchlist = true;
  bool _isWatchlistLoading = false;
  int? _watchlistItemId;
  Map<String, dynamic>? _movieDetails;
  List<dynamic> _cast = [];
  bool _isLoadingDetails = true;
  String? _trailerVideoId;

  @override
  void initState() {
    super.initState();
    _checkIfUserReviewed();
    _loadMovieReviews();
    _checkWatchlistStatus();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final tmdbService = TmdbService();

      final details = await tmdbService.getMovieWithDetails(widget.movie.id);
      final credits = await tmdbService.getMovieCredits(widget.movie.id);
      final videos = await tmdbService.getMovieVideos(widget.movie.id);

      log('Videos response: $videos');

      // Find trailer video ID
      String? videoId;
      final videoList = videos['results'] as List? ?? [];

      log('Video list count: ${videoList.length}');

      // First try to find Trailer
      for (var v in videoList) {
        log('Video: type=${v['type']}, site=${v['site']}, key=${v['key']}');
        if (v['type'] == 'Trailer' && v['site'] == 'YouTube') {
          videoId = v['key'];
          break;
        }
      }

      // If no Trailer, try Teaser
      if (videoId == null) {
        for (var v in videoList) {
          if (v['type'] == 'Teaser' && v['site'] == 'YouTube') {
            videoId = v['key'];
            break;
          }
        }
      }

      // If still no video, take any YouTube video
      if (videoId == null && videoList.isNotEmpty) {
        for (var v in videoList) {
          if (v['site'] == 'YouTube') {
            videoId = v['key'];
            break;
          }
        }
      }

      log('Final trailer videoId: $videoId');

      if (mounted) {
        setState(() {
          _movieDetails = details;
          _cast = (credits['cast'] as List? ?? []).take(10).toList();
          _trailerVideoId = videoId;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      log('Error loading movie details: $e');
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  Future<void> _checkWatchlistStatus() async {
    try {
      final watchlistService = WatchlistServices();
      final result = await watchlistService.checkMovieInWatchlist(
        widget.movie.id,
      );

      if (result['success'] == true) {
        setState(() {
          _isInWatchlist = result['in_watchlist'] ?? false;
          _isCheckingWatchlist = false;
        });
      }

      // If in watchlist, get the watchlist item id
      if (_isInWatchlist) {
        final listResult = await watchlistService.getWatchlist();
        if (listResult['success'] == true) {
          final items = listResult['data'] as List;
          final item = items.firstWhere(
            (i) => i['movie_id'] == widget.movie.id,
            orElse: () => null,
          );
          if (item != null) {
            setState(() {
              _watchlistItemId = item['id'];
            });
          }
        }
      } else {
        setState(() {
          _isCheckingWatchlist = false;
        });
      }
    } catch (e) {
      log('Error checking watchlist: $e');
      setState(() {
        _isCheckingWatchlist = false;
      });
    }
  }

  Future<void> _toggleWatchlist() async {
    if (_isWatchlistLoading) return;
    setState(() {
      _isWatchlistLoading = true;
    });
    try {
      final watchlistService = WatchlistServices();

      if (_isInWatchlist && _watchlistItemId != null) {
        // REMOVE from watchlist
        final result = await watchlistService.removeMovieFromWatchlist(
          _watchlistItemId!,
        );
        if (result['success'] == true) {
          setState(() {
            _isInWatchlist = false;
            _watchlistItemId = null;
          });
          _showTopNotification(
            context,
            '${widget.movie.title} removed from watchlist',
            Colors.orange,
          );
        } else {
          _showTopNotification(
            context,
            result['message'] ?? 'Failed to remove',
            AppTheme.errorColor,
          );
        }
      } else {
        // ADD to watchlist
        final result = await watchlistService.addMovieToWatchlist(
          movieId: widget.movie.id,
          movieTitle: widget.movie.title,
          posterPath: widget.movie.posterPath ?? '',
        );
        if (result['success'] == true) {
          setState(() {
            _isInWatchlist = true;
            _watchlistItemId = result['data']?['id'];
          });
          _showTopNotification(
            context,
            '${widget.movie.title} added to watchlist',
            Colors.green,
          );
        } else {
          _showTopNotification(
            context,
            result['message'] ?? 'Failed to add to watchlist',
            AppTheme.errorColor,
          );
        }
      }
    } catch (e) {
      log('Watchlist error: $e');
      _showTopNotification(context, 'Connection error', AppTheme.errorColor);
    } finally {
      setState(() {
        _isWatchlistLoading = false;
      });
    }
  }

  Future<void> _checkIfUserReviewed() async {
    try {
      final reviewService = ReviewServices();

      // Get user's reviews
      final result = await reviewService.getMyReviews();

      if (result['success'] == true) {
        final reviews = result['data'] as List;

        // Check if user already reviewed this movie
        final existingReview = reviews.firstWhere(
          (review) => review['movie_id'] == widget.movie.id,
          orElse: () => null,
        );

        setState(() {
          _hasReviewed = existingReview != null;
          _existingReviewId = existingReview?['id'];
          _isCheckingReview = false;
        });
      } else {
        setState(() {
          _isCheckingReview = false;
        });
      }
    } catch (e) {
      log('Error checking review: $e');
      setState(() {
        _isCheckingReview = false;
      });
    }
  }

  Future<void> _loadMovieReviews() async {
    try {
      final reviewService = ReviewServices();

      // Get all reviews for this movie
      final result = await reviewService.getReviewsByMovie(widget.movie.id);

      if (result['success'] == true) {
        setState(() {
          _movieReviews = result['data'] as List;
          _averageRating = (result['averageRating'] ?? 0.0).toDouble();
          _totalReviews = result['totalReviews'] ?? 0;
          _isLoadingReviews = false;
        });
      } else {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  void _showTopNotification(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10, // ← Top position
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor, // ← Green for success, Red for error
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  backgroundColor == Colors.green
                      ? Icons.check_circle
                      : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove(); // ← Auto dismiss
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMovieBanner(context),
            _buildMovieInfo(),
            _buildRating(),
            _buildCastSection(),
            _buildSynopsis(),
            _buildReviewsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(context),
    );
  }

  Widget _buildMovieBanner(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 500,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            image: widget.movie.posterPath != null
                ? DecorationImage(
                    image: NetworkImage(
                      TmdbService.getPosterUrl(widget.movie.posterPath),
                    ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.backgroundColor.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        Positioned(
          top: 150,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (_trailerVideoId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrailerPlayerScreen(
                        videoId: _trailerVideoId!,
                        movieTitle: widget.movie.title,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trailer tidak tersedia'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 40,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.movie.releaseDate ?? '',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            widget.movie.title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_movieDetails?['runtime'] != null)
                _buildInfoChip('${_movieDetails!['runtime']} menit'),
              _buildInfoChip('Movie'),
              if (_movieDetails?['certification'] != null &&
                  _movieDetails!['certification'].toString().isNotEmpty)
                _buildInfoChip(_movieDetails!['certification']),
              // Add genres
              if (_movieDetails?['genres'] != null)
                ...(_movieDetails!['genres'] as List)
                    .take(2) // Limit to 2 genres to avoid overflow
                    .map((genre) => _buildInfoChip(genre['name'] ?? '')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
      ),
    );
  }

  Widget _buildRating() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Show user reviews rating if available
          if (_totalReviews > 0) ...[
            const Icon(Icons.star, color: AppTheme.starColor, size: 24),
            const SizedBox(width: 8),
            Text(
              '${_averageRating.toStringAsFixed(1)}/10',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.secondaryColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.people,
                    color: AppTheme.textPrimary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_totalReviews ${_totalReviews == 1 ? 'review' : 'reviews'}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ] else
            // Show placeholder when no reviews yet
            Row(
              children: [
                const Icon(Icons.star_border, color: Colors.grey, size: 24),
                const SizedBox(width: 8),
                Text(
                  'No ratings yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCastSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cast',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: _cast.isEmpty
              ? const Center(
                  child: Text(
                    'No cast information',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _cast.length,
                  itemBuilder: (context, index) {
                    final actor = _cast[index];
                    return _buildCastItem(actor);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCastItem(dynamic actor) {
    final profilePath = actor['profile_path'];
    final imageUrl = profilePath != null
        ? TmdbService.getProfileUrl(profilePath)
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 90,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 80,
                      height: 100,
                      color: AppTheme.surfaceColor,
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 100,
                    color: AppTheme.surfaceColor,
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.textSecondary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynopsis() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Synopsis',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.movie.overview,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(top: BorderSide(color: AppTheme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isCheckingWatchlist || _isWatchlistLoading
                  ? null
                  : _toggleWatchlist,
              icon: _isWatchlistLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      _isInWatchlist
                          ? Icons.bookmark_remove
                          : Icons.bookmark_add_outlined,
                    ),
              label: Text(
                _isCheckingWatchlist
                    ? 'Checking...'
                    : (_isInWatchlist ? 'Remove' : 'Add to watchlist'),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                backgroundColor: _isInWatchlist
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : AppTheme.surfaceColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: _isInWatchlist
                      ? AppTheme.primaryColor
                      : AppTheme.dividerColor,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isCheckingReview
                  ? null
                  : () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (modalContext) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(
                              modalContext,
                            ).viewInsets.bottom,
                          ),
                          child: ReviewModal(
                            movieTitle: widget.movie.title,
                            movieID: widget.movie.id,
                            posterPath: widget.movie.posterPath ?? '',
                            isUpdate: _hasReviewed,
                            existingReviewId: _existingReviewId,
                            onReviewSubmitted: (message) {
                              _showTopNotification(
                                context,
                                message,
                                Colors.green,
                              );
                              _checkIfUserReviewed();
                              _loadMovieReviews();
                            },
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: AppTheme.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isCheckingReview
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _hasReviewed ? 'Update review' : 'Give a review',
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_totalReviews > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_totalReviews',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (_movieReviews.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllReviewsPage(
                          movieTitle: widget.movie.title,
                          movieId: widget.movie.id,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'See all',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _isLoadingReviews
            ? const SizedBox(
                height: 160,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              )
            : _movieReviews.isEmpty
            ? SizedBox(
                height: 160,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No reviews yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Be the first to review this movie!',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _movieReviews.length > 5
                      ? 5
                      : _movieReviews.length,
                  itemBuilder: (context, index) {
                    final review = _movieReviews[index];
                    return _buildReviewCard(review);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildReviewCard(dynamic review) {
    final userName = review['user']?['name'] ?? 'Anonymous';
    final rating = review['rating'] ?? 0;
    final content = review['content'] ?? '';
    final reviewContext = review['context'] ?? '';
    final createdAt = review['created_at'] ?? '';
    final photoPath = review['photo_path'];

    // Format date
    String formattedDate = 'Recently';
    if (createdAt.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        formattedDate = 'Recently';
      }
    }

    return Container(
      width: photoPath != null ? 280 : 220,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review photo (if available)
          if (photoPath != null && photoPath.toString().isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  // Use full URL with storage path
                  'http://10.0.2.2:8000/storage/$photoPath',
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 60,
                    height: 80,
                    color: AppTheme.dividerColor,
                    child: const Icon(
                      Icons.image,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          // Review content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: User info
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 16,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Context chip
                if (reviewContext.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reviewContext,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),

                // Rating and date
                Row(
                  children: [
                    const Icon(Icons.star, color: AppTheme.starColor, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '$rating/10',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Review content
                Expanded(
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
