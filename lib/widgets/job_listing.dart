import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scraping/providers/favorites_provider.dart';
import 'package:web_scraping/utils/utils.dart';

import '../providers/job_provider.dart';

class JobListings extends StatelessWidget {
  const JobListings({
    super.key,
    required ScrollController scrollController,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer2<JobsProvider, FavoritesProvider>(
          builder: (context, jobsProvider, favoritesProvider, _) {
        if (jobsProvider.isLoading && jobsProvider.jobAds.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (!jobsProvider.hasMoreData && jobsProvider.jobAds.isEmpty) {
          return const Center(child: Text("No jobs found"));
        } else {
          return ListView.builder(
            controller: _scrollController,
            itemCount:
                jobsProvider.jobAds.length + (jobsProvider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == jobsProvider.jobAds.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final jobAd = jobsProvider.jobAds[index];
              bool isUpwork = jobAd.url.contains('upwork');
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Text(
                      isUpwork ? 'U' : 'F',
                      style: TextStyle(
                          color: isUpwork ? Colors.green : Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        favoritesProvider.isFavorite(jobAd.title)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: favoritesProvider.isFavorite(jobAd.title)
                            ? Colors.red
                            : Colors.grey,
                      ),
                      onPressed: () => favoritesProvider.toggleFavorite(jobAd),
                    ),
                    title: GestureDetector(
                      child: Text(removeHtmlTags(jobAd.title)),
                      onTap: () async => await EasyLauncher.url(url: jobAd.url),
                    ),
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
