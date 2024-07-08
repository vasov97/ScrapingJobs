import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scraping/providers/job_provider.dart';

class JobFilters extends StatelessWidget {
  const JobFilters({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Checkbox(
            value: context.watch<JobsProvider>().entryLevel,
            onChanged: context.read<JobsProvider>().toggleEntryLevel,
          ),
          const Text('Entry'),
          Checkbox(
            value: context.watch<JobsProvider>().intermediateLevel,
            onChanged: context.read<JobsProvider>().toggleIntermediateLevel,
          ),
          const Text('Intermediate'),
          Checkbox(
            value: context.watch<JobsProvider>().expertLevel,
            onChanged: context.read<JobsProvider>().toggleExpertLevel,
          ),
          const Text('Expert'),
        ],
      ),
    );
  }
}
