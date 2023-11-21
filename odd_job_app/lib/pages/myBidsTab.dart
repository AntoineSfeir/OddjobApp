import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/bid.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/compute_time_to_display.dart';

class MyBidsViewTab extends StatefulWidget {
  final List<Job> myJobs;
  const MyBidsViewTab({super.key, required this.myJobs});

  @override
  State<MyBidsViewTab> createState() => _MyBidsViewTabState();
}

class _MyBidsViewTabState extends State<MyBidsViewTab> {
  final _bidController = TextEditingController();

  late final List<Job> myJobs;
  computeTime computedTime = computeTime();

  void initState() {
    super.initState();
    myJobs = widget.myJobs;
  }

  @override
  void dispose() {
    _bidController.dispose();
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
                  style: TextStyle(color: Colors.grey),
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
                                  ' Currrent Bid Amount: ${bid.amount}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(80),
                                    child: Form(
                                      child: TextFormField(
                                        controller: _bidController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Edit your bid',
                                        ),
                                        onTap: () {},
                                      ),
                                    )),
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to the accept job page
                                  },
                                  child: Text('Change Bid'),
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
