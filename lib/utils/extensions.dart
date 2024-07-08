import 'package:flutter/material.dart';
import 'package:web_scraping/pages/favorites_page.dart';

extension NavigationExtensions on BuildContext {
  void navigateToFavorites() {
    Navigator.of(this).push(MaterialPageRoute(
      builder: (context) => const FavoritesPage(),
    ));
  }
}
