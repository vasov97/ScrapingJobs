import 'package:bloc/bloc.dart';
import 'package:web_scraping/job_ad.dart';
import 'package:web_scraping/repository/jobs_repository.dart';

part 'jobs_state.dart';

class JobsCubit extends Cubit<JobsState> {
  final JobsRepository _repository;
  int _currentPage = 1;
  String query = 'flutter';
  bool entryLevel = false;
  bool intermediateLevel = false;
  bool expertLevel = false;

  JobsCubit(this._repository) : super(JobsInitial());

  void getJobs() async {
    if (state is JobsLoading || !state.hasMoreData) return;

    emit(JobsLoading(state.jobs, state.favoriteJobs));
    for (int page = 1; page <= 5; page++) {
      final newJobs = await _repository.fetchJobs(
        page: _currentPage,
        query: query,
        entryLevel: entryLevel,
        intermediateLevel: intermediateLevel,
        expertLevel: expertLevel,
      );
      if (newJobs.isEmpty) {
        emit(JobsLoaded(state.jobs, state.favoriteJobs, hasMoreData: false));
      } else {
        _currentPage++;
        emit(JobsLoaded([...state.jobs, ...newJobs], state.favoriteJobs));
      }
    }
  }

  void searchJobs(String query) {
    this.query = query;
    _currentPage = 1;
    emit(JobsInitial());
    getJobs();
  }

  void toggleEntryLevel(bool? value) {
    entryLevel = value ?? false;
    _currentPage = 1;
    emit(JobsInitial());
    getJobs();
  }

  void toggleIntermediateLevel(bool? value) {
    intermediateLevel = value ?? false;
    _currentPage = 1;
    emit(JobsInitial());
    getJobs();
  }

  void toggleExpertLevel(bool? value) {
    expertLevel = value ?? false;
    _currentPage = 1;
    emit(JobsInitial());
    getJobs();
  }

  void toggleFavorite(JobAd jobAd) async {
    final List<JobAd> updatedFavorites;
    if (state.favoriteJobs.any((job) => job.url == jobAd.url)) {
      updatedFavorites =
          state.favoriteJobs.where((job) => job.url != jobAd.url).toList();
    } else {
      updatedFavorites = [...state.favoriteJobs, jobAd];
    }
    emit(JobsLoaded(state.jobs, updatedFavorites,
        hasMoreData: state.hasMoreData));
  }
}
