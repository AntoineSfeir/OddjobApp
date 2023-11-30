import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/checkout/go_to_checkout.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class JobRatingsPage extends StatefulWidget {
  final Job jobToReview;
  final String workerUserName;

  JobRatingsPage({required this.jobToReview, required this.workerUserName});

  @override
  State<StatefulWidget> createState() => _JobRatingsState();
}

class _JobRatingsState extends State<JobRatingsPage> {
  late final thisJob;
  late String userToReview;
  double communicationRating = 0;
  double workQualityRating = 0;
  double wouldHireAgainRating = 0;
  double trustScoreRating = 0;
  String review = '';

  // Future<void> getUserToReview() async {
  //   await FirebaseFirestore.instance.collection('users').get().then(
  //         (snapshot) => snapshot.docs.forEach((document) {
  //           if (document.reference.id == thisJob.workerID) {
  //             setState(() {
  //               userToReview = document['username'];
  //             });
  //           }
  //         }),
  //       );
  // }

  @override
  void initState() {
    super.initState();
    thisJob = widget.jobToReview;
    userToReview = widget.workerUserName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate $userToReview'), // Display the user's name
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildRatingRow(
                'Communication:',
                communicationRating,
                (rating) => setState(() => communicationRating = rating),
              ),
              const SizedBox(height: 20),
              buildRatingRow(
                'Work Quality:',
                workQualityRating,
                (rating) => setState(() => workQualityRating = rating),
              ),
              const SizedBox(height: 20),
              buildRatingRow(
                'Would Hire Again:',
                wouldHireAgainRating,
                (rating) => setState(() => wouldHireAgainRating = rating),
              ),
              const SizedBox(height: 20),
              buildRatingRow(
                'Trust Score:',
                trustScoreRating,
                (rating) => setState(() => trustScoreRating = rating),
              ),
              const SizedBox(height: 20),
              const Text(
                'Review:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Type your review here',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onChanged: (value) {
                  // Logic to save the review
                  review = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GoToCheckout(jobToCheckout: thisJob)),
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRatingRow(
      String label, double rating, Function(double) onRatingChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemSize: 30,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: onRatingChanged,
        ),
      ],
    );
  }
}
