import 'package:cineview/presentation/screen/popular_page.dart';
import 'package:cineview/presentation/widgets/movie_card.dart';
import 'package:cineview/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:cineview/data/models/dummy_data_film.dart';

class FilmPopulerSection extends StatelessWidget {
  const FilmPopulerSection({super.key, required this.film});

  final List<DummyDataFilm> film;

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
              MaterialPageRoute(builder: (context) => const PopularPage()),
            );
          },
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: film.length,
            itemBuilder: (context, index) {
              return MovieCard(film: film[index]);
            },
          ),
        ),
      ],
    );
  }
}
