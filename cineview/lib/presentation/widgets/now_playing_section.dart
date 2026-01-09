import 'package:cineview/data/models/dummy_data_film.dart';
import 'package:cineview/presentation/screen/movie_detail_screen.dart';
import 'package:cineview/presentation/screen/popular_page.dart';
import 'package:cineview/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';

class NowPlayingSection extends StatelessWidget {
  const NowPlayingSection({super.key, required this.film});
  final List<DummyDataFilm> film;

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
              MaterialPageRoute(builder: (context) => const PopularPage()),
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,  // Lebih tinggi untuk poster besar
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: film.length,
            itemBuilder: (context, index) {
              return _buildNowPlayingCard(context, film[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNowPlayingCard(BuildContext context, DummyDataFilm movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(film: movie),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(movie.image),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}