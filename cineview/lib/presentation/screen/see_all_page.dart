import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/movie_model.dart';
import 'package:cineview/data/models/actor_model.dart';
import 'package:cineview/presentation/widgets/actor_card.dart';

enum SeeAllType { movie, actor }

class SeeAllPage extends StatelessWidget {
  final String title;
  final SeeAllType type;
  final List<MovieModel>? movies;
  final List<ActorModel>? actors;
  final Function(MovieModel)? onMovieTap;
  final Function(ActorModel)? onActorTap;

  const SeeAllPage({
    super.key,
    required this.title,
    required this.type,
    this.movies,
    this.actors,
    this.onMovieTap,
    this.onActorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (type) {
      case SeeAllType.movie:
        return _buildMovieGrid();
      case SeeAllType.actor:
        return _buildActorGrid();
    }
  }

  Widget _buildMovieGrid() {
    if (movies == null || movies!.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada film',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final limitedMovies = movies!.take(20).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: limitedMovies.length,
      itemBuilder: (context, index) {
        final movie = limitedMovies[index];
        return _buildMovieCard(movie);
      },
    );
  }

  Widget _buildMovieCard(MovieModel movie) {
    final posterUrl = 'https://image.tmdb.org/t/p/w500${movie.posterPath}';

    return GestureDetector(
      onTap: () => onMovieTap?.call(movie),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                posterUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.surfaceColor,
                    child: const Icon(
                      Icons.movie,
                      color: AppTheme.textSecondary,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActorGrid() {
    if (actors == null || actors!.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada aktor',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final limitedActors = actors!.take(20).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: limitedActors.length,
      itemBuilder: (context, index) {
        return ActorCard(
          actor: limitedActors[index],
          onTap: () => onActorTap?.call(limitedActors[index]),
        );
      },
    );
  }
}
