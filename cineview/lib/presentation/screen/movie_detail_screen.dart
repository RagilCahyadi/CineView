import 'dart:developer';

import 'package:cineview/data/services/review_services.dart';
import 'package:cineview/presentation/widgets/review_modal.dart';
import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/dummy_data_film.dart';
import 'package:cineview/data/services/watchlist_services.dart';

class MovieDetailScreen extends StatefulWidget {
  final DummyDataFilm film;

  const MovieDetailScreen({super.key, required this.film});

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

  @override
  void initState() {
    super.initState();
    _checkIfUserReviewed();
    _loadMovieReviews();
    _checkWatchlistStatus();
  }

  Future<void> _checkWatchlistStatus() async {
    try {
      final watchlistService = WatchlistServices();
      final result = await watchlistService.checkMovieInWatchlist(
        widget.film.id,
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
            (i) => i['movie_id'] == widget.film.id,
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
            '${widget.film.title} removed from watchlist',
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
          movieId: widget.film.id,
          movieTitle: widget.film.title,
          posterPath: widget.film.image,
        );
        if (result['success'] == true) {
          setState(() {
            _isInWatchlist = true;
            _watchlistItemId = result['data']?['id'];
          });
          _showTopNotification(
            context,
            '${widget.film.title} added to watchlist',
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
          (review) => review['movie_id'] == widget.film.id,
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
      final result = await reviewService.getReviewsByMovie(widget.film.id);

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
            image: DecorationImage(
              image: AssetImage(widget.film.image),
              fit: BoxFit.cover,
            ),
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
            widget.film.releaseDate,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            widget.film.title,
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
              _buildInfoChip('${widget.film.duration} menit'),
              _buildInfoChip('Movie'),
              _buildInfoChip(widget.film.genre.first),
              _buildInfoChip(widget.film.ageRating),
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
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.film.cast.length,
            itemBuilder: (context, index) {
              final actor = widget.film.cast[index];
              return _buildCastItem(actor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCastItem(Map<String, String> actor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 90,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              actor['image'] ?? 'assets/images/avatar.jpg',
              width: 80,
              height: 100,
              fit: BoxFit.cover,
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
            widget.film.synopsis,
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
                            movieTitle: widget.film.title,
                            movieID: widget.film.id,
                            posterPath: widget.film.image,
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
              if (_movieReviews.length > 3)
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all reviews page
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
    final context = review['context'] ?? '';
    final createdAt = review['created_at'] ?? '';

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
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: User info and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 18,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Context chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              context,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Rating
          Row(
            children: [
              const Icon(Icons.star, color: AppTheme.starColor, size: 18),
              const SizedBox(width: 4),
              Text(
                '$rating/10',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Review content
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}