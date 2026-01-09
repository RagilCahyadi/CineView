import 'package:cineview/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ReviewModal extends StatefulWidget {
  const ReviewModal({super.key, required this.movieTitle});
  final String movieTitle;

  @override
  State<ReviewModal> createState() => _ReviewModalState();
}

class _ReviewModalState extends State<ReviewModal> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  bool _hasError = false;
  bool _isSubmitted = false;

  void _showTopNotification(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  backgroundColor == Colors.green
                      ? Icons.check_circle
                      : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _rating > 0 ? '${_rating.toDouble()}/10' : 'SCORE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(10, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: AppTheme.starColor,
                  size: 24,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _hasError && _contextController.text.isEmpty
                    ? Colors.red
                    : AppTheme.primaryColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _contextController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: _hasError && _contextController.text.isEmpty
                    ? 'Need To Write A Context'
                    : 'Write A Context',
                hintStyle: TextStyle(
                  color: _hasError && _contextController.text.isEmpty
                      ? Colors.red
                      : Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.edit,
                  color: _hasError && _contextController.text.isEmpty
                      ? Colors.red
                      : Colors.grey,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _hasError && _reviewController.text.isEmpty
                    ? Colors.red
                    : AppTheme.primaryColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _reviewController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: _hasError && _reviewController.text.isEmpty
                    ? 'Need To Write A Review'
                    : 'Write A Review',
                hintStyle: TextStyle(
                  color: _hasError && _reviewController.text.isEmpty
                      ? Colors.red
                      : Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.edit,
                  color: _hasError && _reviewController.text.isEmpty
                      ? Colors.red
                      : Colors.grey,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_rating == 0 ||
                    _contextController.text.isEmpty ||
                    _reviewController.text.isEmpty) {
                  setState(() {
                    _hasError = true;
                  });
                  return;
                }
                setState(() {
                  _hasError = false;
                  _isSubmitted = true;
                });
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pop(context);
                  _showTopNotification(
                    context,
                    'Review submitted successfully! Rating: $_rating/10',
                    Colors.green,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Give a review',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
