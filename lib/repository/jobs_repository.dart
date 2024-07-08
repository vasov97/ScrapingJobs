import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:web_scraping/job_ad.dart';

class JobsRepository {
  Future<List<JobAd>> fetchJobs({
    required int page,
    required String query,
    required bool entryLevel,
    required bool intermediateLevel,
    required bool expertLevel,
  }) async {
    var url =
        Uri.parse('https://www.upwork.com/nx/search/jobs/?q=$query&page=$page');
    if (entryLevel) {
      url = Uri.parse(
          'https://www.upwork.com/nx/search/jobs/?contractor_tier=1&q=$query&sort=recency&page=$page');
    } else if (intermediateLevel) {
      url = Uri.parse(
          'https://www.upwork.com/nx/search/jobs/?contractor_tier=2&q=$query&sort=recency&page=$page');
    } else if (expertLevel) {
      url = Uri.parse(
          'https://www.upwork.com/nx/search/jobs/?contractor_tier=3&q=$query&sort=recency&page=$page');
    }

    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    final titles =
        html.querySelectorAll('h2 > a').map((e) => e.innerHtml.trim()).toList();

    final urls = html
        .querySelectorAll('h2 > a')
        .map((e) => 'https://www.upwork.com${e.attributes['href']}')
        .toList();

    return List.generate(
      titles.length,
      (index) => JobAd(
        title: titles[index],
        url: urls[index],
      ),
    );
  }
}
