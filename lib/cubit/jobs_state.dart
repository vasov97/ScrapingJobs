part of 'jobs_cubit.dart';

abstract class JobsState {
  final List<JobAd> jobs;
  final List<JobAd> favoriteJobs;
  final bool hasMoreData;

  JobsState(this.jobs, this.favoriteJobs, {this.hasMoreData = true});
}

class JobsInitial extends JobsState {
  JobsInitial() : super([], []);
}

class JobsLoading extends JobsState {
  JobsLoading(super.jobs, super.favoriteJobs);
}

class JobsLoaded extends JobsState {
  JobsLoaded(super.jobs, super.favoriteJobs, {super.hasMoreData});
}
