import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/jobdescription.dart';
import 'package:odd_job_app/jobs/compute_time_to_display.dart';
import 'package:odd_job_app/jobs/geolocation/compute_distance.dart';
import 'package:odd_job_app/jobs/user.dart';

//import 'package:geolocator/geolocator.dart';

// ignore: must_be_immutable

//import 'package:geolocator/geolocator.dart';

// ignore: must_be_immutable
class JobCard extends StatelessWidget {
  late final Job job;
  late final user currentUser;
  ComputeDistance computedDistance = ComputeDistance();
  computeTime computedTime = computeTime();
  final String cardBackground = '#1B475E';
  final String moneyText = '#8BD5FF';
  late final Color cardBackgroundColor =
      Color(int.parse(cardBackground.substring(1, 7), radix: 16) + 0xFF000000);
  late final Color moneyTextColor =
      Color(int.parse(moneyText.substring(1, 7), radix: 16) + 0xFF000000);


  //used for sortByDistance
  static ComputeDistance? _computedDistance;
  static user? _currentUser;

  JobCard({Key? key, required this.job, required this.currentUser}) : super(key: key) {
    _computedDistance = ComputeDistance();
    _currentUser = currentUser;
  }

  static int sortByBid(JobCard a, JobCard b) {
    int cardA = int.parse(a.job.startingBid);
    int cardB = int.parse(b.job.startingBid);
    return cardA.compareTo(cardB);
  }

  static int sortByDistance(JobCard a, JobCard b) {
    if (_computedDistance == null || _currentUser == null) {
      // Handle the case when _computedDistance or _currentUser is not set
      return 0;
    }

    double distanceA = double.parse(_computedDistance!.compute(_currentUser!.currentLocation, a.job.longlat));
    double distanceB = double.parse(_computedDistance!.compute(_currentUser!.currentLocation, b.job.longlat));
    return distanceA.compareTo(distanceB);
  }

  static int sortByTime(JobCard a, JobCard b) {
    Timestamp local = Timestamp.now();
    Duration timeRemainingA = a.job.deadline.toDate().difference(local.toDate());
  Duration timeRemainingB = b.job.deadline.toDate().difference(local.toDate());
  return timeRemainingA.compareTo(timeRemainingB);
  }



  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobDescriptionPage(ID: job.ID),
        ),
      ),
      child: Card(
        color: cardBackgroundColor,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(15.0), // Adjust the radius as needed
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                job.title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Current Bid',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '\$',
                        style: TextStyle(
                          color: moneyTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        job.startingBid,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: moneyTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                // set current user geo location
                children: <Widget>[
                  Text(
                    '${computedDistance.compute(currentUser.currentLocation, job.longlat)} miles',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    computedTime.compute(job.deadline),
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
