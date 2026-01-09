import 'dart:async';

import 'package:cineview/data/models/dummy_data_film.dart';
import 'package:cineview/presentation/screen/main_navigation.dart';
import 'package:cineview/presentation/widgets/featured_card.dart';
import 'package:cineview/presentation/widgets/film_populer_section.dart';
import 'package:cineview/presentation/widgets/search_bar_widget.dart';
import 'package:cineview/presentation/widgets/watchlist_section.dart';
import 'package:cineview/presentation/widgets/hot_trailer_section.dart';
import 'package:cineview/presentation/widgets/top_actor_section.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < contents.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuint,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100, top: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBarWidget(),
                const SizedBox(height: 10),
                _buildFeaturedCarousel(),
                const SizedBox(height: 10),
                WatchlistSection(film: contents),
                FilmPopulerSection(film: contents),
                const SizedBox(height: 20),
                const HotTrailerSection(),
                const SizedBox(height: 20),
                const TopActorSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return SizedBox(
      height: 450,
      child: PageView.builder(
        controller: _pageController,
        itemCount: contents.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return FeaturedCard(film: contents[index]);
        },
      ),
    );
  }
}
