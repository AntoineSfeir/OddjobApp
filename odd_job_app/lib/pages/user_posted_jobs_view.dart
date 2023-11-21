import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/bid.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/pages/accept_job_page.dart';
import 'package:odd_job_app/pages/other_profile_page.dart';
import 'package:odd_job_app/jobs/compute_time_to_display.dart';

class UsersPostedJobsView extends StatefulWidget {
  final List<Job> myJobs;

  const UsersPostedJobsView({super.key, required this.myJobs});

  @override
  State<UsersPostedJobsView> createState() => _UsersPostedJobsViewState();
}

class _UsersPostedJobsViewState extends State<UsersPostedJobsView> {
  late final List<Job> myJobs;
  computeTime computedTime = computeTime();

  @override
  void initState() {
    super.initState();
    print("LOADED");
    myJobs = widget.myJobs;
    print("MYJOBSLENGTH = ${myJobs.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: myJobs.length,
        itemBuilder: (context, index) {
          List<bid> bidsForJob = myJobs[index].bids;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 3,
              child: ExpansionTile(
                title: Text(
                  myJobs[index].title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  computedTime.compute(myJobs[index].deadline),
                  style: const TextStyle(color: Colors.grey),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Job Description:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          myJobs[index].description,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: bidsForJob.map((bid) {
                            return Row(
                              children: [
                                const Icon(Icons.monetization_on),
                                const SizedBox(width: 4),
                                Text(
                                  'Bid Amount: ${bid.amount}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OtherProfilePage(
                                                  recieverUser: bid.bidder,
                                                )),
                                      );
                                    },
                                    child: Text(bid.bidder.username)),
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to the accept job page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AcceptJobPage(
                                            thisBid: bid,
                                            theJob: myJobs[index]),
                                      ),
                                    );
                                  },
                                  child: const Text('Accept Job'),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
