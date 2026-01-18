import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cineview/core/theme/app_theme.dart';

class TrailerPlayerScreen extends StatelessWidget {
  final String videoId;
  final String movieTitle;

  const TrailerPlayerScreen({
    super.key,
    required this.videoId,
    required this.movieTitle,
  });

  Future<void> _playTrailer() async {
    final youtubeAppUrl = 'youtube://watch?v=$videoId';
    final webUrl = 'https://www.youtube.com/watch?v=$videoId';

    final appUri = Uri.parse(youtubeAppUrl);
    final webUri = Uri.parse(webUrl);

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl =
        'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          movieTitle,
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Thumbnail dengan play button
            GestureDetector(
              onTap: _playTrailer,
              child: Container(
                width: double.infinity,
                height: 220,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.surfaceColor,
                  image: DecorationImage(
                    image: NetworkImage(thumbnailUrl),
                    fit: BoxFit.cover,
                    onError: (e, s) {},
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black38,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 80,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              movieTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _playTrailer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Trailer', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
