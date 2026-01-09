import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/presentation/screen/popular_page.dart';
import 'package:cineview/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:cineview/data/models/dummy_data_actor.dart';

class TopActorSection extends StatelessWidget {
  const TopActorSection({super.key});

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
              MaterialPageRoute(builder: (context) => const PopularPage()),
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: actors.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _buildActorItem(actors[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActorItem(DummyDataActor actor) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surfaceColor,
            border: Border.all(color: AppTheme.dividerColor, width: 2),
            image: DecorationImage(
              image: AssetImage(actor.image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          actor.firstName,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
        ),
        Text(
          actor.lastName,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 11),
        ),
      ],
    );
  }
}