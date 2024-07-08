import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scraping/providers/favorites_provider.dart';
import 'package:web_scraping/utils/utils.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Jobs'),
      ),
      body: Consumer<FavoritesProvider>(builder: (context, provider, child) {
        final favoriteJobs = provider.favoriteJobs;
        return ListView.builder(
          itemCount: favoriteJobs.length,
          itemBuilder: (context, index) {
            final jobAd = favoriteJobs[index];
            return Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.toggleFavorite(jobAd),
                ),
                title: GestureDetector(
                  child: Text(removeHtmlTags(jobAd.title)),
                  onTap: () async => await EasyLauncher.url(url: jobAd.url),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
