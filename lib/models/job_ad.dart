class JobAd {
  final String url;
  final String title;

  const JobAd({required this.url, required this.title});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
    };
  }

  factory JobAd.fromMap(Map<String, dynamic> map) {
    return JobAd(
      title: map['title'],
      url: map['url'],
    );
  }
}
