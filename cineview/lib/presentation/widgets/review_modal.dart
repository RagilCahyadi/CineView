import 'dart:io';
import 'dart:developer';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:cineview/data/services/review_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReviewModal extends StatefulWidget {
  const ReviewModal({
    super.key,
    required this.movieTitle,
    required this.movieID,
    this.posterPath,
    this.onReviewSubmitted,
    this.isUpdate = false,
    this.existingReviewId,
  });

  final String movieTitle;
  final int movieID;
  final String? posterPath;
  final Function(String message)? onReviewSubmitted;
  final bool isUpdate;
  final int? existingReviewId;

  @override
  State<ReviewModal> createState() => _ReviewModalState();
}

class _ReviewModalState extends State<ReviewModal> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  bool _hasError = false;
  bool _isLoading = false;
  bool _isLoadingReview = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _existingPhotoPath;

  @override
  void dispose() {
    _reviewController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.existingReviewId != null) {
      _loadExistingReview();
    }
  }

  Future<void> _loadExistingReview() async {
    setState(() {
      _isLoadingReview = true;
    });

    try {
      final reviewServices = ReviewServices();
      final result = await reviewServices.getMyReviews();

      if (result['success'] == true) {
        final reviews = result['data'] as List;

        // Cara paling aman: for loop
        dynamic review;
        for (var r in reviews) {
          if (r['id'] == widget.existingReviewId) {
            review = r;
            break;
          }
        }

        if (review != null && mounted) {
          // Debug: Print photo path
          log('Loaded review photo path: ${review['photo_path']}');
          
          setState(() {
            _rating = review['rating'] ?? 0;
            _contextController.text = review['context'] ?? '';
            _reviewController.text = review['content'] ?? '';
            _existingPhotoPath = review['photo_path'];
            _isLoadingReview = false;
          });
        } else {
          setState(() {
            _isLoadingReview = false;
          });
          
          if (mounted) {
            _showTopNotification(
              context,
              'Review not found',
              Colors.red,
            );
          }
        }
      } else {
        setState(() {
          _isLoadingReview = false;
        });
        
        if (mounted) {
          _showTopNotification(
            context,
            'Failed to load reviews',
            Colors.red,
          );
        }
      }
    } catch (e) {
      log('Error loading review: $e');
      setState(() {
        _isLoadingReview = false;
      });

      if (mounted) {
        _showTopNotification(context, 'Failed to load review data', Colors.red);
      }
    }
  }

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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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

  Future<void> _submitReview() async {
    // Validation
    if (_rating == 0 ||
        _contextController.text.isEmpty ||
        _reviewController.text.isEmpty) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final reviewService = ReviewServices();
      Map<String, dynamic> result;

      if (widget.isUpdate && widget.existingReviewId != null) {
        // Update existing review
        result = await reviewService.updateReview(
          reviewId: widget.existingReviewId!,
          rating: _rating,
          context: _contextController.text,
          content: _reviewController.text,
          photoFile: _selectedImage,
        );
      } else {
        // Create new review
        result = await reviewService.createReview(
          movieId: widget.movieID,
          movieTitle: widget.movieTitle,
          rating: _rating,
          context: _contextController.text,
          content: _reviewController.text,
          photoFile: _selectedImage,
        );
      }

      // Stop loading
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        // Tutup modal
        if (mounted) {
          Navigator.pop(context);
        }

        final message = widget.isUpdate
            ? 'Review updated successfully! Rating: $_rating/10'
            : 'Review submitted successfully! Rating: $_rating/10';
        widget.onReviewSubmitted?.call(message);
      } else {
        if (mounted) {
          _showTopNotification(
            context,
            result['message'] ?? 'Failed to submit review',
            Colors.red,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showTopNotification(context, 'Connection error: $e', Colors.red);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showTopNotification(context, 'Failed to pick image: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while fetching review data
    if (_isLoadingReview) {
      return Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              SizedBox(height: 16),
              Text(
                'Loading review data...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Movie poster (if available)
            if (widget.posterPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  widget.posterPath!,
                  height: 80,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),

            // Movie title
            Text(
              widget.movieTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Rating score display
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

            // Star rating selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(10, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                      _hasError = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: AppTheme.starColor,
                      size: 28,
                    ),
                  ),
                );
              }),
            ),

            // Error message for rating
            if (_hasError && _rating == 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please select a rating',
                  style: TextStyle(color: Colors.red[400], fontSize: 12),
                ),
              ),

            const SizedBox(height: 24),

            // Context input
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
                      ? 'Context is required'
                      : 'Write a context (e.g., Action, Drama)',
                  hintStyle: TextStyle(
                    color: _hasError && _contextController.text.isEmpty
                        ? Colors.red
                        : Colors.grey[500],
                  ),
                  prefixIcon: Icon(
                    Icons.category,
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
                onChanged: (_) {
                  if (_hasError) {
                    setState(() {
                      _hasError = false;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Review content input
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
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: _hasError && _reviewController.text.isEmpty
                      ? 'Review is required'
                      : 'Write your review here...',
                  hintStyle: TextStyle(
                    color: _hasError && _reviewController.text.isEmpty
                        ? Colors.red
                        : Colors.grey[500],
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Icon(
                      Icons.edit,
                      color: _hasError && _reviewController.text.isEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (_) {
                  if (_hasError) {
                    setState(() {
                      _hasError = false;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Photo upload section
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppTheme.surfaceColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              title: const Text(
                                'Camera',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                              ),
                              title: const Text(
                                'Gallery',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                            // Add option to remove photo if updating
                            if (widget.isUpdate && (_selectedImage != null || _existingPhotoPath != null))
                              ListTile(
                                leading: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                title: const Text(
                                  'Remove Photo',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _selectedImage = null;
                                    _existingPhotoPath = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: AppTheme.primaryColor),
                        SizedBox(height: 4),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Show selected image (new upload)
                if (_selectedImage != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: -5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                // Show existing photo from server
                else if (_existingPhotoPath != null && _existingPhotoPath!.isNotEmpty)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          // FIX: Gunakan URL lengkap dengan http://
                          'http://10.0.2.2:8000/storage/$_existingPhotoPath',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // Debug: Print error
                            log('Image load error: $error');
                            log('Image path: $_existingPhotoPath');
                            
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Failed',
                                    style: TextStyle(
                                      color: Colors.red[300],
                                      fontSize: 8,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: -5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _existingPhotoPath = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: AppTheme.secondaryColor.withOpacity(
                    0.5,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.isUpdate
                            ? 'Update Review'
                            : 'Submit Review', // ← Dynamic text
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
