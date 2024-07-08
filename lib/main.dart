import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scraping/pages/home_page.dart';
import 'package:web_scraping/providers/favorites_provider.dart';
import 'package:web_scraping/providers/job_provider.dart';
import 'package:web_scraping/service/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobsProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Upwork Jobs',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 26, 230, 118)),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}
