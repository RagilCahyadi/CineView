import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/movie_model.dart';
import 'package:cineview/data/services/tmdb_service.dart';
import 'package:cineview/presentation/screen/see_all_page.dart';
import 'package:cineview/presentation/widgets/section_header.dart';

class NowPlayingSection extends StatelessWidget {
  final List<MovieModel> movies;
  final bool isLoading;
  final Function(MovieModel)? onMovieTap;

  const NowPlayingSection({
    super.key,
    required this.movies,
    this.isLoading = false,
    this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Now Playing",
          onSeeAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeeAllPage(
                  title: 'Now Playing',
                  type: SeeAllType.movie,
                  movies: movies,
                  onMovieTap: onMovieTap,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        isLoading ? _buildLoadingState() : _buildMovieList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 280,
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildMovieList() {
    if (movies.isEmpty) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: Text(
            'Tidak ada film',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: movies.length > 5 ? 5 : movies.length,
        itemBuilder: (context, index) {
          MovieModel movie = movies[index];
          return _buildNowPlayingCard(context, movie);
        },
      ),
    );
  }

  Widget _buildNowPlayingCard(BuildContext context, MovieModel movie) {
    String posterUrl = TmdbService.getPosterUrl(movie.posterPath);

    return GestureDetector(
      onTap: () {
        if (onMovieTap != null) {
          onMovieTap!(movie);
        }
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.surfaceColor,
          image: DecorationImage(
            image: NetworkImage(posterUrl),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {},
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
        ),
      ),
    );
  }
}
