import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scraping/providers/favorites_provider.dart';
import 'package:web_scraping/providers/job_provider.dart';
import 'package:web_scraping/utils/extensions.dart';
import 'package:web_scraping/widgets/job_filters.dart';
import 'package:web_scraping/widgets/job_listing.dart';
import 'package:web_scraping/widgets/search_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    context.read<JobsProvider>().getJobs();
    context.read<FavoritesProvider>().loadFavorites();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<JobsProvider>().getJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<JobsProvider>().searchJobs('Flutter'),
        child: const Icon(Icons.refresh),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Freelance Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => context.navigateToFavorites(),
          ),
        ],
      ),
      body: Column(
        children: [
          MySearchBar(
            searchController: _searchController,
            onSearch: () =>
                context.read<JobsProvider>().searchJobs(_searchController.text),
          ),
          const Text('Select filters only for Upwork jobs'),
          const JobFilters(),
          JobListings(scrollController: _scrollController),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
