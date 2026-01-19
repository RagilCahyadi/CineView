import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/services/tmdb_service.dart';
import 'package:cineview/presentation/screen/trailer_player_screen.dart';
import 'package:cineview/presentation/widgets/section_header.dart';

class HotTrailerSection extends StatefulWidget {
  const HotTrailerSection({super.key});

  @override
  State<HotTrailerSection> createState() => _HotTrailerSectionState();
}

class _HotTrailerSectionState extends State<HotTrailerSection> {
  final TmdbService _tmdbService = TmdbService();
  List<Map<String, dynamic>> _trailers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrailers();
  }

  Future<void> _loadTrailers() async {
    try {
      final trailers = await _tmdbService.getHotTrailers(limit: 5);
      if (mounted) {
        setState(() {
          _trailers = trailers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Hot Trailer"),
        const SizedBox(height: 12),
        _isLoading ? _buildLoadingState() : _buildTrailerList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildTrailerList() {
    if (_trailers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          height: 180,
          child: Center(
            child: Text(
              'Tidak ada trailer',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _trailers.length,
        itemBuilder: (context, index) {
          return _buildTrailerCard(_trailers[index]);
        },
      ),
    );
  }

  Widget _buildTrailerCard(Map<String, dynamic> trailerData) {
    final movie = trailerData['movie'];
    final trailer = trailerData['trailer'];
    final String thumbnailUrl = trailerData['thumbnail'] ?? '';
    final String movieTitle = movie['title'] ?? '';
    final String videoId = trailer['key'] ?? '';

    return GestureDetector(
      onTap: () {
        if (videoId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TrailerPlayerScreen(videoId: videoId, movieTitle: movieTitle),
            ),
          );
        }
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.surfaceColor,
          image: thumbnailUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(thumbnailUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                )
              : null,
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppTheme.textPrimary,
                  size: 32,
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Text(
                movieTitle,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
