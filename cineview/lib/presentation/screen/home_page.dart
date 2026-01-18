import 'dart:async';
import 'dart:developer';

import 'package:cineview/presentation/widgets/now_playing_section.dart';
import 'package:cineview/presentation/widgets/tmdb_featured_card.dart';
import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/movie_model.dart';
import 'package:cineview/data/models/actor_model.dart';
import 'package:cineview/data/services/tmdb_service.dart';
import 'package:cineview/presentation/widgets/film_populer_section.dart';
import 'package:cineview/presentation/widgets/search_bar_widget.dart';
import 'package:cineview/presentation/widgets/hot_trailer_section.dart';
import 'package:cineview/presentation/widgets/top_actor_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  final TmdbService _tmdbService = TmdbService();

  List<MovieModel> _trendingMovies = [];
  List<MovieModel> _popularMovies = [];
  List<MovieModel> _nowPlayingMovies = [];
  List<ActorModel> _trendingActors = [];

  bool _isLoadingTrending = true;
  bool _isLoadingPopular = true;
  bool _isLoadingNowPlaying = true;
  bool _isLoadingActors = true;

  @override
  void initState() {
    super.initState();

    _loadAllData();
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCarouselTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_trendingMovies.isEmpty) return;
      int totalItems = _trendingMovies.length > 5 ? 5 : _trendingMovies.length;
      if (_currentPage < totalItems - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      // Animasi scroll
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuint,
        );
      }
    });
  }

  Future<void> _loadAllData() async {
    _loadTrendingMovies();
    _loadPopularMovies();
    _loadNowPlayingMovies();
    _loadTrendingActors();
  }

  Future<void> _loadTrendingMovies() async {
    try {
      final result = await _tmdbService.getTrendingMovies();

      final List<dynamic> jsonList = result['results'] ?? [];
      final List<MovieModel> movies = jsonList
          .map((json) => MovieModel.fromJson(json))
          .toList();

      setState(() {
        _trendingMovies = movies;
        _isLoadingTrending = false;
      });
    } catch (error) {
      log('Error loading trending movies: $error');
      setState(() {
        _isLoadingTrending = false;
      });
    }
  }

  Future<void> _loadPopularMovies() async {
    try {
      final result = await _tmdbService.getPopularMovies();

      final List<dynamic> jsonList = result['results'] ?? [];
      final List<MovieModel> movies = jsonList
          .map((json) => MovieModel.fromJson(json))
          .toList();

      setState(() {
        _popularMovies = movies;
        _isLoadingPopular = false;
      });
    } catch (error) {
      log('Error loading popular movies: $error');
      setState(() {
        _isLoadingPopular = false;
      });
    }
  }

  Future<void> _loadNowPlayingMovies() async {
    try {
      final result = await _tmdbService.getNowPlayingMovies();

      final List<dynamic> jsonList = result['results'] ?? [];
      final List<MovieModel> movies = jsonList
          .map((json) => MovieModel.fromJson(json))
          .toList();

      setState(() {
        _nowPlayingMovies = movies;
        _isLoadingNowPlaying = false;
      });
    } catch (error) {
      log('Error loading now playing movies: $error');
      setState(() {
        _isLoadingNowPlaying = false;
      });
    }
  }

  Future<void> _loadTrendingActors() async {
    try {
      final result = await _tmdbService.getTrendingPeople();

      final List<dynamic> jsonList = result['results'] ?? [];
      final List<ActorModel> actors = jsonList
          .map((json) => ActorModel.fromJson(json))
          .toList();

      setState(() {
        _trendingActors = actors;
        _isLoadingActors = false;
      });
    } catch (error) {
      log('Error loading trending actors: $error');
      setState(() {
        _isLoadingActors = false;
      });
    }
  }

  void _navigateToMovieDetail(MovieModel movie) {
    log('Navigate to: ${movie.title}');
  }

  void _navigateToActorDetail(ActorModel actor) {
    log('Navigate to: ${actor.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SearchBarWidget(),
            const SizedBox(height: 10),

            _buildFeaturedCarousel(),
            const SizedBox(height: 10),

            FilmPopulerSection(
              movies: _popularMovies,
              isLoading: _isLoadingPopular,
              onMovieTap: _navigateToMovieDetail,
            ),
            const SizedBox(height: 10),

            const HotTrailerSection(),
            TopActorSection(
              actors: _trendingActors,
              isLoading: _isLoadingActors,
              onActorTap: _navigateToActorDetail,
            ),
            const SizedBox(height: 20),
            NowPlayingSection(
              movies: _nowPlayingMovies,
              isLoading: _isLoadingNowPlaying,
              onMovieTap: _navigateToMovieDetail,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk Featured Carousel
  Widget _buildFeaturedCarousel() {
    if (_isLoadingTrending) {
      return const SizedBox(
        height: 450,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    if (_trendingMovies.isEmpty) {
      return const SizedBox(
        height: 450,
        child: Center(
          child: Text(
            'Tidak ada film trending',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 450,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _trendingMovies.length > 5 ? 5 : _trendingMovies.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          MovieModel movie = _trendingMovies[index];

          return TmdbFeaturedCard(
            movie: movie,
            currentIndex: _currentPage,
            totalCount: _trendingMovies.length > 5 ? 5 : _trendingMovies.length,
            onMoreInfo: () => _navigateToMovieDetail(movie),
            onAddToWatchlist: () {
              // TODO: Implementasi add to watchlist
              log('Add to watchlist: ${movie.title}');
            },
          );
        },
      ),
    );
  }
}
