import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final videoUrls = [
  'https://www.youtube.com/watch?v=8Ve5SAFPYZ8',
  'https://www.youtube.com/watch?v=5AxWC49ZMzs',
  'https://www.youtube.com/watch?v=JSqUZFkRLr8',
  'https://www.youtube.com/watch?v=qEZf2q4W20g',
  'https://www.youtube.com/watch?v=jCbclWBV32o',
];

final videoImages = [
  'https://img.youtube.com/vi/8Ve5SAFPYZ8/maxresdefault.jpg',
  'https://img.youtube.com/vi/5AxWC49ZMzs/maxresdefault.jpg',
  'https://img.youtube.com/vi/JSqUZFkRLr8/maxresdefault.jpg',
  'https://img.youtube.com/vi/qEZf2q4W20g/maxresdefault.jpg',
  'https://img.youtube.com/vi/jCbclWBV32o/maxresdefault.jpg',
];

class Feed extends StatelessWidget {
  const Feed({super.key});

  /// Fonction pour ouvrir l'URL dans YouTube ou navigateur
  Future<void> _openVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Ouvre l’app YouTube si dispo
      );
    } else {
      throw 'Impossible d’ouvrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      scrollDirection: Axis.horizontal, // Défilement horizontal
      itemCount: videoUrls.length,
      itemBuilder: (context, index) {
        final videoUrl = videoUrls[index];
        final thumbnailUrl = videoImages[index];

        return Container(
          width: screenWidth * 0.6, // Largeur fixe pour chaque vignette
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openVideo(videoUrl), // Ouvre YouTube
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  height:
                      double.infinity, // Utilise toute la hauteur disponible
                  errorBuilder: (context, error, stackTrace) {
                    return thumbnailFallback();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Fallback si la miniature ne se charge pas
  Widget thumbnailFallback() {
    return Container(
      height: 200,
      color: Colors.blueGrey,
      child: const Center(
        child: Text(
          "Aperçu non disponible",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
