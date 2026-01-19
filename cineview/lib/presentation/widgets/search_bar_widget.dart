import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/movie_model.dart';
import 'package:cineview/data/services/tmdb_service.dart';
import 'package:cineview/presentation/screen/movie_detail_screen.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    this.hintText = "Mencari sesuatu?",
    this.showTuneIcon = false,
    this.onFilterTap,
  });

  final String hintText;
  final bool showTuneIcon;
  final VoidCallback? onFilterTap;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TmdbService _tmdbService = TmdbService();
  final TextEditingController _controller = TextEditingController();
  List<MovieModel> _results = [];
  bool _isLoading = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _tmdbService.searchMovies(query: query);
      final List<dynamic> data = response['results'] ?? [];

      if (mounted) {
        setState(() {
          _results = data.take(5).map((e) => MovieModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearAndNavigate(MovieModel movie) {
    setState(() {
      _results = [];
      _controller.clear();
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SearchBar(
            controller: _controller,
            hintText: widget.hintText,
            hintStyle: const WidgetStatePropertyAll(
              TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
            leading: const Icon(Icons.search, color: AppTheme.textSecondary),
            trailing: widget.showTuneIcon
                ? [
                    GestureDetector(
                      onTap: widget.onFilterTap,
                      child: const Icon(
                        Icons.tune,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ]
                : null,
            onChanged: _search,
            backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
            side: const WidgetStatePropertyAll(
              BorderSide(color: AppTheme.dividerColor),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),

        // Loading indicator
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 2,
              ),
            ),
          )
        // Results list
        else if (_results.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _results.map((movie) {
                return ListTile(
                  leading: movie.posterPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            TmdbService.getPosterUrl(
                              movie.posterPath,
                              size: 'w92',
                            ),
                            width: 40,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.movie, color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.movie, color: Colors.grey),
                  title: Text(
                    movie.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    movie.year,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => _clearAndNavigate(movie),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
