import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/services/tmdb_service.dart';

class FilterModal extends StatefulWidget {
  final List<int>? selectedGenres;
  final int? selectedYear;
  final String? selectedCertification;
  final Function(List<int>?, int?, String?) onApply;

  const FilterModal({
    super.key,
    this.selectedGenres,
    this.selectedYear,
    this.selectedCertification,
    required this.onApply,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final TmdbService _tmdbService = TmdbService();
  List<Map<String, dynamic>> _genres = [];
  bool _isLoadingGenres = true;

  List<int> _selectedGenres = [];
  int? _selectedYear;
  String? _selectedCertification;

  final List<String> _certifications = ['G', 'PG', 'PG-13', 'R', 'NC-17'];
  final List<int> _years = List.generate(35, (i) => 2024 - i);

  @override
  void initState() {
    super.initState();
    _selectedGenres = widget.selectedGenres ?? [];
    _selectedYear = widget.selectedYear;
    _selectedCertification = widget.selectedCertification;
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    try {
      final response = await _tmdbService.getMovieGenres();
      if (mounted) {
        setState(() {
          _genres = List<Map<String, dynamic>>.from(response['genres'] ?? []);
          _isLoadingGenres = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingGenres = false);
    }
  }

  void _reset() {
    setState(() {
      _selectedGenres = [];
      _selectedYear = null;
      _selectedCertification = null;
    });
  }

  void _apply() {
    widget.onApply(
      _selectedGenres.isEmpty ? null : _selectedGenres,
      _selectedYear,
      _selectedCertification,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(onPressed: _reset, child: const Text('Reset')),
            ],
          ),
          const SizedBox(height: 20),

          // Genre Section
          const Text(
            'Genre',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _isLoadingGenres
              ? const CircularProgressIndicator(color: AppTheme.primaryColor)
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _genres.map((genre) {
                    final isSelected = _selectedGenres.contains(genre['id']);
                    return FilterChip(
                      label: Text(genre['name']),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedGenres.add(genre['id']);
                          } else {
                            _selectedGenres.remove(genre['id']);
                          }
                        });
                      },
                      selectedColor: AppTheme.primaryColor,
                      checkmarkColor: Colors.black,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : AppTheme.textPrimary,
                      ),
                      backgroundColor: AppTheme.backgroundColor,
                    );
                  }).toList(),
                ),
          const SizedBox(height: 20),

          // Year Section
          const Text(
            'Tahun Rilis',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: _selectedYear,
            hint: const Text(
              'Pilih tahun',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            dropdownColor: AppTheme.surfaceColor,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: _years
                .map(
                  (year) => DropdownMenuItem(
                    value: year,
                    child: Text(
                      '$year',
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedYear = value),
          ),
          const SizedBox(height: 20),

          // Certification Section
          const Text(
            'Rating Usia',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _certifications.map((cert) {
              final isSelected = _selectedCertification == cert;
              return ChoiceChip(
                label: Text(cert),
                selected: isSelected,
                onSelected: (selected) {
                  setState(
                    () => _selectedCertification = selected ? cert : null,
                  );
                },
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : AppTheme.textPrimary,
                ),
                backgroundColor: AppTheme.backgroundColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 30),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Terapkan Filter',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
