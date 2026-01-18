import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/movie_model.dart';
import 'package:cineview/data/models/genre_model.dart';
import 'package:cineview/data/services/tmdb_service.dart';
import 'package:stroke_text/stroke_text.dart';

class TmdbFeaturedCard extends StatelessWidget {
  final MovieModel movie;
  final int currentIndex;
  final int totalCount;
  final VoidCallback? onMoreInfo;
  final VoidCallback? onAddToWatchlist;

  const TmdbFeaturedCard({
    super.key,
    required this.movie,
    required this.currentIndex,
    required this.totalCount,
    this.onMoreInfo,
    this.onAddToWatchlist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(TmdbService.getBackdropUrl(movie.backdropPath)),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {},
        ),
        color: AppTheme.surfaceColor,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTitle(),

            _buildGenrePills(),

            const SizedBox(height: 12),

            _buildActionButtons(context),

            const SizedBox(height: 16),

            _buildDotsIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return StrokeText(
      text: movie.title,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
      strokeColor: AppTheme.primaryColor,
      strokeWidth: 2,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildGenrePills() {
    List<String> genreNames = GenreModel.getGenreNames(movie.genreIds);

    String genreText = genreNames.take(3).join(' • ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.surfaceColor.withOpacity(0.8),
      ),
      child: Text(
        genreText,
        style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Add to Watchlist Button
        GestureDetector(
          onTap: onAddToWatchlist,
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.5),
              border: Border.all(color: AppTheme.dividerColor),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.add, color: AppTheme.textPrimary),
          ),
        ),

        const SizedBox(width: 12),

        ElevatedButton(
          onPressed: onMoreInfo,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: AppTheme.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text(
            "More Info",
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalCount,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? AppTheme.primaryColor
                : AppTheme.textSecondary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
