import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/movie_model.dart';
import 'package:cineview/presentation/screen/see_all_page.dart';
import 'package:cineview/presentation/widgets/section_header.dart';
import 'package:cineview/presentation/widgets/tmdb_movie_card.dart';

class FilmPopulerSection extends StatelessWidget {
  final List<MovieModel> movies;

  final bool isLoading;

  final Function(MovieModel)? onMovieTap;

  const FilmPopulerSection({
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
          title: "Film Populer",
          onSeeAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeeAllPage(
                  title: 'Film Populer',
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
      height: 180,
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildMovieList() {
    if (movies.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Tidak ada film',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: movies.length > 5 ? 5 : movies.length,
        itemBuilder: (BuildContext context, int index) {
          // Ambil data film pada index ini
          MovieModel movie = movies[index];

          return TmdbMovieCard(
            movie: movie,
            onTap: () {
              if (onMovieTap != null) {
                onMovieTap!(movie);
              }
            },
          );
        },
      ),
    );
  }
}
