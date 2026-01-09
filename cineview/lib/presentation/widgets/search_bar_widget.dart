import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key, this.onChanged, this.onSubmitted});
  
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SearchBar(
        hintText: "Mencari sesuatu?",
        hintStyle: const WidgetStatePropertyAll(
          TextStyle(color: AppTheme.textSecondary, fontSize: 16),
        ),
        leading: const Icon(Icons.search, color: AppTheme.textSecondary),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppTheme.dividerColor),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}