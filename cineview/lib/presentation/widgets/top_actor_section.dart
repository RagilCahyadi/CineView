import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/actor_model.dart';
import 'package:cineview/presentation/screen/see_all_page.dart';
import 'package:cineview/presentation/widgets/section_header.dart';
import 'package:cineview/presentation/widgets/actor_card.dart';

class TopActorSection extends StatelessWidget {
  final List<ActorModel> actors;

  final bool isLoading;

  final Function(ActorModel)? onActorTap;

  const TopActorSection({
    super.key,
    required this.actors,
    this.isLoading = false,
    this.onActorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Top Popular Actor",
          onSeeAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeeAllPage(
                  title: 'Top Popular Actor',
                  type: SeeAllType.actor,
                  actors: actors,
                  onActorTap: onActorTap,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        isLoading ? _buildLoadingState() : _buildActorList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 120,
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildActorList() {
    if (actors.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Tidak ada aktor',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: actors.length > 5 ? 5 : actors.length,
        itemBuilder: (BuildContext context, int index) {
          ActorModel actor = actors[index];

          return ActorCard(
            actor: actor,
            onTap: () {
              if (onActorTap != null) {
                onActorTap!(actor);
              }
            },
          );
        },
      ),
    );
  }
}
