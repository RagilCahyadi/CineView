import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAllTap,
  });

  final String title;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onSeeAllTap,
            child: const Row(
              children: [
                Text(
                  "See all",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.play_circle_filled,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}