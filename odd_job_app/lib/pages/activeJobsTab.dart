import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/bid.dart';
import 'package:odd_job_app/jobs/compute_time_to_display.dart';
import 'package:odd_job_app/jobs/job.dart';

class activeJobsViewTab extends StatefulWidget {
  final List<Job> activeJobs;
  const activeJobsViewTab({super.key, required this.activeJobs});

  @override
  State<activeJobsViewTab> createState() => _activeJobsViewTabState();
}

class _activeJobsViewTabState extends State<activeJobsViewTab> {
  late final List<Job> myJobs;
  late final List<Job> jobsThatIAmWorking = [];
  late final List<Job> jobsThatIAmContracting = [];
  computeTime computedTime = computeTime();

  @override
  void initState() {
    super.initState();
    print("Trying Something");
    myJobs = widget.activeJobs;
    for (int i = 0; i < myJobs.length; i++) {
      if (myJobs[i].working) {
        jobsThatIAmWorking.add(myJobs[i]);
      } else if (!myJobs[i].working) {
        jobsThatIAmContracting.add(myJobs[i]);
      }
    }
    print("MYJOBSLENGTH = ${jobsThatIAmWorking.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: myJobs.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  elevation: 1,
                  child: ExpansionTile(
                    title: Text(
                      myJobs[index].title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )));
        },
      ),
    );
  }
}
