import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_scraping/cubit/jobs_cubit.dart';
import 'package:web_scraping/database_service.dart';
import 'package:web_scraping/favorites_page.dart';
import 'package:web_scraping/job_ad.dart';
import 'package:web_scraping/repository/jobs_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => JobsCubit(JobsRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Upwork Jobs',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 26, 230, 118)),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Upwork Jobs'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List<JobAd> jobAds = [];
  List<JobAd> favoriteJobs = [];
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  // int _currentPage = 1;
  // bool _isLoading = false;
  // bool _hasMoreData = true;
  // String _searchQuery = 'flutter';
  final DatabaseService _databaseService = DatabaseService();
  // bool _entryLevel = false;
  // bool _intermediateLevel = false;
  // bool _expertLevel = false;

  // Future<void> getJobs() async {
  //   if (_isLoading || !_hasMoreData) return;

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   final newJobs = await getData(_currentPage);
  //   setState(() {
  //     jobAds.addAll(newJobs);
  //     _currentPage++;
  //     _isLoading = false;
  //     if (_currentPage > 5) {
  //       _hasMoreData = false;
  //     }
  //   });
  // }

  void searchJobs() {
    context.read<JobsCubit>().searchJobs(_searchController.text);

    // setState(() {
    //   // _currentPage = 1;
    //   // jobAds.clear();
    //   // _searchQuery = _searchController.text;
    //   // _hasMoreData = true;
    //   getJobs();
    // });
  }

  // Future<List<JobAd>> getData(int page) async {
  //   var url = Uri.parse(
  //       'https://www.upwork.com/nx/search/jobs/?q=$_searchQuery&page=$page');
  //   if (_entryLevel) {
  //     url = Uri.parse(
  //         'https://www.upwork.com/nx/search/jobs/?contractor_tier=1&q=$_searchQuery&sort=recency&page=$page');
  //   } else if (_intermediateLevel) {
  //     url = Uri.parse(
  //         'https://www.upwork.com/nx/search/jobs/?contractor_tier=2&q=$_searchQuery&sort=recency&page=$page');
  //   } else if (_expertLevel) {
  //     url = Uri.parse(
  //         'https://www.upwork.com/nx/search/jobs/?contractor_tier=3&q=$_searchQuery&sort=recency&page=$page');
  //   }

  //   final response = await http.get(url);
  //   dom.Document html = dom.Document.html(response.body);

  //   final titles = html
  //       .querySelectorAll('h2 > a')
  //       .map(
  //         (e) => e.innerHtml.trim(),
  //       )
  //       .toList();

  //   final urls = html
  //       .querySelectorAll('h2 > a')
  //       .map((e) => 'https://www.upwork.com${e.attributes['href']}')
  //       .toList();

  //   return List.generate(titles.length,
  //       (index) => JobAd(title: titles[index], url: urls[index]));
  // }

  // void _resetPagination() {
  //   jobAds.clear();
  //   _currentPage = 1;
  //   _hasMoreData = true;
  // }

  // void _toggleEntryLevel(bool? value) {
  //   setState(() {
  //     _entryLevel = value ?? false;
  //     _resetPagination();
  //     getJobs();
  //   });
  // }

  // void _toggleIntermediateLevel(bool? value) {
  //   setState(() {
  //     _intermediateLevel = value ?? false;
  //     _resetPagination();
  //     getJobs();
  //   });
  // }

  // void _toggleExpertLevel(bool? value) {
  //   setState(() {
  //     _expertLevel = value ?? false;
  //     _resetPagination();
  //     getJobs();
  //   });
  // }

  String removeHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<JobsCubit>().getJobs();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    //getJobs();
    context.read<JobsCubit>().getJobs();
    loadFavorites();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> saveFavorite(JobAd jobAd) async {
    if (!favoriteJobs.any((job) => job.url == jobAd.url)) {
      await _databaseService.insertJob(jobAd);
      loadFavorites();
    }
  }

  Future<void> loadFavorites() async {
    final favorites = await _databaseService.getFavoriteJobs();
    setState(() {
      favoriteJobs = favorites;
    });
  }

  Future<void> toggleFavorite(JobAd jobAd) async {
    if (await _databaseService.isFavorite(jobAd.url)) {
      await _databaseService.deleteJob(jobAd.url);
    } else {
      await _databaseService.insertJob(jobAd);
    }
    loadFavorites();
  }

  bool isFavorite(String url) {
    return favoriteJobs.any((job) => job.url == url);
  }

  void navigateToFavorites() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FavoritesPage(
        favoriteJobs: favoriteJobs,
        onRemoveFavorite: toggleFavorite,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<JobsCubit>().getJobs(),
        child: const Icon(Icons.refresh),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: navigateToFavorites,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for jobs...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: searchJobs,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: context.watch<JobsCubit>().entryLevel,
                  onChanged: (value) =>
                      context.read<JobsCubit>().toggleEntryLevel(value),
                ),
                const Text('Entry'),
                Checkbox(
                  value: context.watch<JobsCubit>().intermediateLevel,
                  onChanged: (value) =>
                      context.read<JobsCubit>().toggleIntermediateLevel(value),
                ),
                const Text('Intermediate'),
                Checkbox(
                  value: context.watch<JobsCubit>().expertLevel,
                  onChanged: (value) =>
                      context.read<JobsCubit>().toggleExpertLevel(value),
                ),
                const Text('Expert'),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<JobsCubit, JobsState>(
              builder: (context, state) {
                if (state is JobsInitial || state is JobsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is JobsLoaded) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.jobs.length + (state.hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.jobs.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final jobAd = state.jobs[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 3,
                          child: ListTile(
                            trailing: IconButton(
                              icon: Icon(
                                isFavorite(jobAd.url)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite(jobAd.url)
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () => toggleFavorite(jobAd),
                            ),
                            title: GestureDetector(
                              child: Text(removeHtmlTags(jobAd.title)),
                              onTap: () async =>
                                  await EasyLauncher.url(url: jobAd.url),
                            ),
                            //subtitle: Text(jobAd.url),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('Failed to load jobs'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
