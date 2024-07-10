import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:web_scraping/models/job_ad.dart';

class JobsProvider with ChangeNotifier {
  List<JobAd> jobAds = [];
  List<JobAd> favoriteJobs = [];
  int _currentPage = 1;
  bool isLoading = false;
  bool hasMoreData = true;
  String _searchQuery = 'flutter';
  bool entryLevel = false;
  bool intermediateLevel = false;
  bool expertLevel = false;

  JobsProvider() {
    getJobs();
  }

  Future<void> getJobs() async {
    if (isLoading || !hasMoreData) return;

    isLoading = true;
    notifyListeners();

    final freelanceJobs = await fetchFreelancerJobs(_currentPage);
    final upworkJobs = await fetchJobs(_currentPage);
    final allJobs = [...upworkJobs, ...freelanceJobs];
    allJobs.sort((a, b) => a.title.compareTo(b.title));
    jobAds.addAll(allJobs);
    _currentPage++;
    isLoading = false;
    if (_currentPage > 5) {
      hasMoreData = false;
    }
    notifyListeners();
  }

  Future<List<JobAd>> fetchFreelancerJobs(int page) async {
    final url = Uri.parse(
        'https://www.freelancer.com/jobs/flutter/$page/?w=f&redirect-times=1&ngsw-bypass=');
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    final titles = html
        .querySelectorAll('.JobSearchCard-primary-heading-link')
        .map((e) => e.innerHtml.trim())
        .toList();
    final urls = html
        .querySelectorAll('.JobSearchCard-primary-heading-link')
        .map((e) => 'https://www.freelancer.com${e.attributes['href']}')
        .toList();

    return List.generate(titles.length,
        (index) => JobAd(title: titles[index], url: urls[index]));
  }

  Future<List<JobAd>> fetchJobs(int page) async {
    var url = Uri.parse(
        'https://www.upwork.com/nx/search/jobs/?q=$_searchQuery&page=$page');
    String contractorTiers = '';

    if (entryLevel) {
      contractorTiers += '1,';
    }
    if (intermediateLevel) {
      contractorTiers += '2,';
    }
    if (expertLevel) {
      contractorTiers += '3,';
    }

    if (contractorTiers.isNotEmpty) {
      contractorTiers =
          contractorTiers.substring(0, contractorTiers.length - 1);
      url = Uri.parse(
          'https://www.upwork.com/nx/search/jobs/?contractor_tier=$contractorTiers&q=$_searchQuery&sort=recency&page=$page');
    } else {
      url = Uri.parse(
          'https://www.upwork.com/nx/search/jobs/?q=$_searchQuery&sort=recency&page=$page');
    }

    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    final titles = html
        .querySelectorAll('h2 > a')
        .map(
          (e) => e.innerHtml.trim(),
        )
        .toList();

    final urls = html
        .querySelectorAll('h2 > a')
        .map((e) => 'https://www.upwork.com${e.attributes['href']}')
        .toList();

    return List.generate(titles.length,
        (index) => JobAd(title: titles[index], url: urls[index]));
  }

  void searchJobs(String query) {
    _searchQuery = query;
    resetPagination();
    getJobs();
  }

  void resetPagination() {
    jobAds.clear();
    _currentPage = 1;
    hasMoreData = true;
    notifyListeners();
  }

  void toggleEntryLevel(bool? value) {
    entryLevel = value ?? false;
    resetPagination();
    getJobs();
  }

  void toggleIntermediateLevel(bool? value) {
    intermediateLevel = value ?? false;
    resetPagination();
    getJobs();
  }

  void toggleExpertLevel(bool? value) {
    expertLevel = value ?? false;
    resetPagination();
    getJobs();
  }
}
