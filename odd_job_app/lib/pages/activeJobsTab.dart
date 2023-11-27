import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/jobs/checkout/checkout_page.dart';
import 'package:odd_job_app/jobs/checkout/go_to_checkout.dart';
import 'package:odd_job_app/jobs/compute_time_to_display.dart';
import 'package:odd_job_app/pages/job_rating_page.dart';

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

    myJobs = widget.activeJobs;
    for (int i = 0; i < myJobs.length; i++) {
      print("Working bool value ${myJobs[i].working}");
      if (myJobs[i].working == 'true') {
        jobsThatIAmWorking.add(myJobs[i]);
      } else if (myJobs[i].working == 'false') {
        jobsThatIAmContracting.add(myJobs[i]);
      }
    }
    print("${jobsThatIAmContracting.length} bitch");
    print("${jobsThatIAmWorking.length} bitch1");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: ListView(
        children: [
          _buildContractExpansionTile("Contracts", jobsThatIAmContracting),
          _buildWorkerExpansionTile("Working", jobsThatIAmWorking),
        ],
      ),
    );
  }

  Widget _buildContractExpansionTile(String title, List<Job> jobs) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 1,
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: _buildContractJobList(jobs),
        ),
      ),
    );
  }

  Widget _buildWorkerExpansionTile(String title, List<Job> jobs) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 1,
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: _buildWorkerJobList(jobs),
        ),
      ),
    );
  }

  List<Widget> _buildContractJobList(List<Job> jobs) {
    return jobs.map((job) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title: ${job.title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Address: ${job.address}',
              ),
              Text(
                'Deadline: ${computedTime.compute(job.deadline)}',
              ),
              Row(
                children: [
                  Text(
                    'Worker: ${job.displayName}',
                  ),
                  IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () {
                      // Handle the action when the message icon is clicked
                      // For example, you can open a chat with the worker
                      print(
                          'Message icon clicked for worker: ${job.displayName}');
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Status: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            //   builder: (context) => GoToCheckout(jobToCheckout: job)),
                            builder: (context) =>
                                JobRatingsPage(jobToReview: job)),
                      );
                    },
                    child: const Text('Finished'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                    onPressed: () {
                      // Handle the action when "Not Finished" is pressed
                    },
                    child: const Text('Not Finished'),
                  ),
                ],
              ),
              // Add other details or actions related to the job
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildWorkerJobList(List<Job> jobs) {
    return jobs.map((job) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title: ${job.title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Client: ${job.displayName}',
              ),
              Text(
                'Address: ${job.address}',
              ),
              Text(
                'Deadline: ${computedTime.compute(job.deadline)}',
              ),
              Text(
                'Description: ${job.description}',
              ),
              Row(
                children: [
                  const Text(
                    'Job Finished? ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                    onPressed: () {},
                    child: const Text('YES'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                    onPressed: () {},
                    child: const Text('NO'),
                  ),
                ],
              ),
              // Add other details or actions related to the job
            ],
          ),
        ),
      );
    }).toList();
  }
}
