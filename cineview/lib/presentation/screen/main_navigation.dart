import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/presentation/screen/home_page.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(
      child: Text(
        'Collection Page',
        style: TextStyle(color: AppTheme.textPrimary),
      ),
    ),
    const Center(
      child: Text(
        'Explore Page',
        style: TextStyle(color: AppTheme.textPrimary),
      ),
    ),
    const Center(
      child: Text(
        'User Profil Page',
        style: TextStyle(color: AppTheme.textPrimary),
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Dashboard'),
          _buildNavItem(1, Icons.format_list_bulleted_rounded, 'Users Profile'),
          _buildNavItem(
            2,
            Icons.play_circle_outline_rounded,
            'Explore',
            reversed: true,
          ),
          _buildNavItem(
            3,
            Icons.person_outline_rounded,
            'User Profil',
            reversed: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label, {
    bool reversed = false,
  }) {
    bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.dividerColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive && label.isNotEmpty && reversed) ...[
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
            ],
            if (isActive)
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.textPrimary, size: 22),
              )
            else
              Icon(icon, color: AppTheme.textSecondary, size: 28),
            if (isActive && label.isNotEmpty && !reversed) ...[
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
