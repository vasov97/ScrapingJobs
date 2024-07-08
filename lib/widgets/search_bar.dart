import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;

  const MySearchBar({
    super.key,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search for jobs...',
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearch,
          ),
        ),
      ),
    );
  }
}
