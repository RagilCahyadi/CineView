import 'package:cineview/presentation/widgets/review%20_modal.dart';
import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/dummy_data_film.dart';

class MovieDetailScreen extends StatelessWidget {
  final DummyDataFilm film;

  const MovieDetailScreen({super.key, required this.film});
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
              image: AssetImage(film.image),
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
            film.releaseDate,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            film.title,
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
              _buildInfoChip('${film.duration} menit'),
              _buildInfoChip('Movie'),
              _buildInfoChip(film.genre.first),
              _buildInfoChip(film.ageRating),
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
          const Icon(Icons.star, color: AppTheme.starColor, size: 24),
          const SizedBox(width: 8),
          Text(
            '${film.rating}/10',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '(${film.voteCount} votes)',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
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
            itemCount: film.cast.length,
            itemBuilder: (context, index) {
              final actor = film.cast[index];
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
            film.synopsis,
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
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppTheme.dividerColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Add to watchlist',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ReviewModal(movieTitle: film.title),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Give a review',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final List<Map<String, String>> reviews = [
      {
        'username': 'CCrusader',
        'date': 'April 20, 2025',
        'title': 'Great Movie!',
        'rating': '8',
        'content':
            'Minecraft movie is enchanted and more. It\'s like a box of Legos...',
      },
      {
        'username': 'alex_gamer',
        'date': 'April 20, 2025',
        'title': 'Entertaining, but that\'s it',
        'rating': '7',
        'content':
            'As a longtime Minecraft player for this movie-and while it didn\'t disappoint either.',
      },
      {
        'username': 'movie_fan',
        'date': 'April 18, 2025',
        'title': 'Fun for the whole family',
        'rating': '9',
        'content':
            'Took my kids to see this and they absolutely loved it! Great adaptation.',
      },
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reviews',
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
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return _buildReviewCard(review);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, String> review) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
              Text(
                review['date'] ?? '',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['title'] ?? '',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, color: AppTheme.starColor, size: 16),
              const SizedBox(width: 4),
              Text(
                '${review['rating']}/10',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              '${review['content']} (${review['username']})',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
