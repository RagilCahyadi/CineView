import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/dummy_data_actor.dart';
import 'package:cineview/data/models/dummy_data_film.dart';
import 'package:flutter/material.dart';

class ActorDetailPage extends StatelessWidget {
  final DummyDataActor actor;

  const ActorDetailPage({super.key, required this.actor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(context),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameSection(),
                  SizedBox(height: 24),

                  _buildStatsRow(),
                  SizedBox(height: 24),

                  _buildInfoCards(),
                  SizedBox(height: 24),

                  _buildBiography(),
                  SizedBox(height: 24),

                  _buildFilmography(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return Container(
      height: 380,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            height: 380,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(actor.image),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            height: 380,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  AppTheme.backgroundColor.withOpacity(0.9),
                  AppTheme.backgroundColor,
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),

          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(Icons.favorite_border, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          actor.fullName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Popular Actor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.movie_creation_outlined,
            value: '${actor.movies.length}',
            label: 'Movies',
          ),

          Container(width: 1, height: 50, color: AppTheme.dividerColor),

          _buildStatItem(
            icon: Icons.star_outline,
            value: '4.9',
            label: 'Rating',
          ),

          Container(width: 1, height: 50, color: AppTheme.dividerColor),

          _buildStatItem(
            icon: Icons.emoji_events_outlined,
            value: '12',
            label: 'Awards',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.cake_outlined,
            title: 'Birthday',
            subtitle: actor.birthDate,
          ),
        ),
        SizedBox(width: 16),

        Expanded(
          child: _buildInfoCard(
            icon: Icons.location_on_outlined,
            title: 'Birthplace',
            subtitle: actor.birthPlace,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 22),
          ),
          SizedBox(height: 14),

          Text(
            title,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          SizedBox(height: 4),

          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBiography() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Biography',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            actor.biography,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilmography() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Filmography',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${actor.movies.length} Films',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: actor.movies.length,
            itemBuilder: (context, index) {
              return _buildFilmCard(actor.movies[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilmCard(DummyDataFilm film) {
    return Container(
      width: 130,
      margin: EdgeInsets.only(right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image: AssetImage(film.image),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        SizedBox(width: 3),
                        Text(
                          film.rating,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          Text(
            film.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          Text(
            film.year,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
