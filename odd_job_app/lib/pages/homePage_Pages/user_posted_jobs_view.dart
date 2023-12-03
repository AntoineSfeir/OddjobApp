import 'package:flutter/material.dart';
import 'package:odd_job_app/jobAssets/bid.dart';
import 'package:odd_job_app/jobAssets/job.dart';
import 'package:odd_job_app/oddjob_colors.dart';
import 'package:odd_job_app/pages/jobs_Pages/accept_job_page.dart';
import 'package:odd_job_app/jobAssets/compute_time_to_display.dart';
import 'package:odd_job_app/pages/profile_Pages/other_profile_page.dart';

class UsersPostedJobsView extends StatefulWidget {
  final List<Job> myJobs;

  const UsersPostedJobsView({Key? key, required this.myJobs}) : super(key: key);

  @override
  State<UsersPostedJobsView> createState() => _UsersPostedJobsViewState();
}

class _UsersPostedJobsViewState extends State<UsersPostedJobsView> {
  late final List<Job> myJobs;
  computeTime computedTime = computeTime();

  @override
  void initState() {
    super.initState();
    myJobs = widget.myJobs;
    findLowestBids();
  }

  void findLowestBids() async {
    for (int i = 0; i < myJobs.length; i++) {
      List<bid> bidsForJob = myJobs[i].bids;

      // Check if the list of bids is not empty before accessing its elements
      if (bidsForJob.isNotEmpty) {
        double minBid = double.parse(bidsForJob[0].amount);

        for (int j = 0; j < bidsForJob.length; j++) {
          double tempBid = double.parse(bidsForJob[j].amount);
          if (tempBid < minBid) {
            minBid = tempBid;
          }
        }

        setState(() {
          myJobs[i].lowestBid = minBid;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: ListView.builder(
        itemCount: myJobs.length,
        itemBuilder: (context, index) {
          List<bid> bidsForJob = myJobs[index].bids;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              myJobs[index].title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              computedTime.compute(myJobs[index].deadline),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          myJobs[index].description,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        ExpansionTile(
                          title: const Text(
                            'Current Bids',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: bidsForJob.length,
                                itemBuilder: (context, index) {
                                  bid currentBid = bidsForJob[index];
                                  return Card(
                                    color: OddJobColors().darkBlueColor,
                                    elevation: 3,
                                    shadowColor: Colors.grey[300],
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20), // Adjust the radius as needed
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 8, 12, 8),
                                      child: ListTile(
                                        title: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    OtherProfilePage(
                                                  recieverUser:
                                                      currentBid.bidder,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors
                                                .indigo, // Set your desired background color
                                          ),
                                          child: Text(
                                            '${currentBid.bidder.username} bid \$${currentBid.amount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        trailing: InkWell(
                                          onTap: () {
                                            // Navigate to the accept job page
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AcceptJobPage(
                                                  thisBid: currentBid,
                                                  theJob: myJobs[index],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Icon(
                                              Icons.add_task,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
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