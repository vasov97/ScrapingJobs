import 'package:flutter/material.dart';
import 'package:web_scraping/models/job_ad.dart';
import 'package:web_scraping/service/database_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<JobAd> _favoriteJobs = [];

  List<JobAd> get favoriteJobs => _favoriteJobs;

  FavoritesProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _favoriteJobs = await _databaseService.getFavoriteJobs();
    notifyListeners();
  }

  Future<void> toggleFavorite(JobAd jobAd) async {
    if (await _databaseService.isFavorite(jobAd.url)) {
      await _databaseService.deleteJob(jobAd.url);
    } else {
      await _databaseService.insertJob(jobAd);
    }
    loadFavorites();
  }

  bool isFavorite(String title) {
    return _favoriteJobs.any((job) => job.title == title);
  }
}
