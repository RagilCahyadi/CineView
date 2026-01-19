import 'package:cineview/data/models/movie_model.dart';
import 'package:cineview/data/services/tmdb_service.dart';
import 'package:cineview/presentation/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/presentation/screen/movie_detail_screen.dart';
import 'package:cineview/presentation/widgets/filter_modal.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchController = TextEditingController();
  final TmdbService _tmdbService = TmdbService();

  final List<String> _categories = [
    'New in Theater',
    'Coming Soon',
    'International',
    'Popular',
    'Top Rated',
  ];

  int _selectedCategory = 0;
  List<MovieModel> _movies = [];
  bool _isLoading = true;
  List<int>? _filterGenres;
  int? _filterYear;
  String? _filterCertification;
  bool _isFiltered = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map result;
      switch (_selectedCategory) {
        case 0: // New in Theater
          result = await _tmdbService.getNowPlayingMovies();
          break;
        case 1: // Coming Soon
          result = await _tmdbService.getUpcomingMovies();
          break;
        case 2: // International (Using Trending as proxy for now)
          result = await _tmdbService.getTrendingMovies();
          break;
        case 3: // Popular
          result = await _tmdbService.getPopularMovies();
          break;
        case 4: // Top Rated
          result = await _tmdbService.getTopRatedMovies();
          break;
        default:
          result = await _tmdbService.getPopularMovies();
      }

      final List<dynamic> results = result['results'];
      setState(() {
        _movies = results.map((e) => MovieModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading movies: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        selectedGenres: _filterGenres,
        selectedYear: _filterYear,
        selectedCertification: _filterCertification,
        onApply: (genres, year, certification) {
          setState(() {
            _filterGenres = genres;
            _filterYear = year;
            _filterCertification = certification;
            _isFiltered =
                genres != null || year != null || certification != null;
          });
          _applyFilters();
        },
      ),
    );
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);

    try {
      final response = await _tmdbService.discoverMovies(
        withGenres: _filterGenres?.join(','),
        primaryReleaseYear: _filterYear,
        certification: _filterCertification,
      );
      final List<dynamic> results = response['results'] ?? [];

      if (mounted) {
        setState(() {
          _movies = results.map((e) => MovieModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Filter error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 20),
                SearchBarWidget(
                  hintText: "Search movies",
                  showTuneIcon: true,
                  onFilterTap: _showFilterModal,
                ),
                const SizedBox(height: 20),
                _buildCategoryChips(),
                const SizedBox(height: 20),
                _buildSectionTitle(),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : _buildMovieGrid(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Now what shall we watch today?',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == index;

          return GestureDetector(
            onTap: () {
              if (_selectedCategory != index) {
                setState(() {
                  _selectedCategory = index;
                });
                _loadMovies();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  if (index == 0)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Text('🔥', style: TextStyle(fontSize: 14)),
                    ),
                  if (index == 1)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Text('⭐', style: TextStyle(fontSize: 14)),
                    ),
                  Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        const Text('🔥', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          _categories[_selectedCategory],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMovieGrid() {
    if (_movies.isEmpty) {
      return const Center(
        child: Text('No movies found.', style: TextStyle(color: Colors.grey)),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        return _buildMovieCard(_movies[index]);
      },
    );
  }

  Widget _buildMovieCard(MovieModel movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.surfaceColor,
                image: movie.posterPath != null
                    ? DecorationImage(
                        image: NetworkImage(
                          TmdbService.getPosterUrl(movie.posterPath),
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: movie.posterPath == null
                  ? const Center(
                      child: Icon(Icons.movie, color: Colors.grey, size: 40),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            movie.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Row(
                children: List.generate(5, (starIndex) {
                  double rating = movie.voteAverage;
                  double starValue = rating / 2;

                  if (starIndex < starValue.floor()) {
                    return const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 14,
                    );
                  } else if (starIndex < starValue) {
                    return const Icon(
                      Icons.star_half,
                      color: Colors.amber,
                      size: 14,
                    );
                  } else {
                    return Icon(
                      Icons.star_border,
                      color: Colors.grey[600],
                      size: 14,
                    );
                  }
                }),
              ),
              const SizedBox(width: 6),
              Text(
                '${movie.voteAverage.toStringAsFixed(1)}/10',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
