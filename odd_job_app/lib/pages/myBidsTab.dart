import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/bid.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/compute_time_to_display.dart';

class MyBidsViewTab extends StatefulWidget {
  final List<bid> myBids;
  const MyBidsViewTab({Key? key, required this.myBids}) : super(key: key);

  @override
  State<MyBidsViewTab> createState() => _MyBidsViewTabState();
}

class _MyBidsViewTabState extends State<MyBidsViewTab> {
  final _bidController = TextEditingController();

  late final List<bid> myJobs;
  computeTime computedTime = computeTime();

  @override
  void initState() {
    super.initState();
    myJobs = widget.myBids;
  }

  @override
  void dispose() {
    super.dispose();
    _bidController.dispose();
  }

  Future changeBid(bid myBid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(myBid.bidder.ID)
        .collection('currentBids')
        .doc(myBid.bidID)
        .set({
      'bidAmount': _bidController.text.trim(),
      'jobID': myBid.jobThatWasBidOn.ID
    });
    print("JOBID : ${myBid.jobThatWasBidOn.ID}");
    print("BIDAMOUNT : ${_bidController.text.trim()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: myJobs.length,
        itemBuilder: (context, index) {
          List<bid> bidsForJob = myJobs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 3,
              child: ExpansionTile(
                title: Text(
                  myJobs[index].jobThatWasBidOn.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  computedTime.compute(myJobs[index].jobThatWasBidOn.deadline),
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
                          myJobs[index].jobThatWasBidOn.description,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: bidsForJob.map((thebid) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.monetization_on),
                                    const SizedBox(width: 4),
                                    Text(
                                      ' Current Bid Amount: ${thebid.amount}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left:
                                          24), // Adjust the left padding as needed
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _bidController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'Edit your bid',
                                          ),
                                          onTap: () {},
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          changeBid(thebid);
                                          // Navigate to the accept job page
                                        },
                                        child: Text('Change Bid'),
                                      ),
                                    ],
                                  ),
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
