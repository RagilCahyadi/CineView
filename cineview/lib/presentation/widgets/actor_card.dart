import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/models/actor_model.dart';
import 'package:cineview/data/services/tmdb_service.dart';

class ActorCard extends StatelessWidget {
  final ActorModel actor;
  final VoidCallback? onTap;

  const ActorCard({super.key, required this.actor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            _buildProfilePhoto(),
            const SizedBox(height: 8),
            _buildActorName(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    String profileUrl = TmdbService.getProfileUrl(actor.profilePath);

    return ClipOval(
      child: Image.network(
        profileUrl,
        height: 80,
        width: 80,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
              return Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: AppTheme.textSecondary,
                  ),
                ),
              );
            },
        loadingBuilder:
            (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) return child;

              return Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            },
      ),
    );
  }

  Widget _buildActorName() {
    return Text(
      actor.name,
      style: const TextStyle(
        fontSize: 12,
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 2,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
  }
}
