import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/movie_model.dart';
import 'package:cineview/data/services/tmdb_service.dart';

class TmdbMovieCard extends StatefulWidget {
  final MovieModel movie;
  final VoidCallback? onTap;

  const TmdbMovieCard({super.key, required this.movie, this.onTap});

  @override
  State<TmdbMovieCard> createState() => _TmdbMovieCardState();
}

class _TmdbMovieCardState extends State<TmdbMovieCard> {
  final TmdbService _tmdbService = TmdbService();
  String? _certification;
  int? _runtime;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final details = await _tmdbService.getMovieWithDetails(widget.movie.id);
      if (mounted) {
        setState(() {
          _runtime = details['runtime'];
          _certification = details['certification'];
          _isLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoaded = true);
      }
    }
  }

  String get _durationDisplay {
    if (_runtime == null) return '';
    final hours = _runtime! ~/ 60;
    final minutes = _runtime! % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPosterImage(),
            const SizedBox(height: 8),
            _buildInfoText(),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterImage() {
    String posterUrl = TmdbService.getPosterUrl(widget.movie.posterPath);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        posterUrl,
        height: 150,
        width: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 150,
            width: 120,
            color: AppTheme.surfaceColor,
            child: const Icon(
              Icons.movie,
              size: 40,
              color: AppTheme.textSecondary,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 150,
            width: 120,
            color: AppTheme.surfaceColor,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoText() {
    List<String> parts = [];

    if (widget.movie.year.isNotEmpty) {
      parts.add(widget.movie.year);
    }

    if (_certification != null && _certification!.isNotEmpty) {
      parts.add(_certification!);
    }

    if (_durationDisplay.isNotEmpty) {
      parts.add(_durationDisplay);
    }

    String infoText = parts.join(' | ');

    return Text(
      infoText.isEmpty ? widget.movie.year : infoText,
      style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
