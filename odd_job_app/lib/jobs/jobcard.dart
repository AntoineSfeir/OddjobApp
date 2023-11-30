import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/jobs/jobdescription.dart';
import 'package:odd_job_app/jobs/compute_time_to_display.dart';
import 'package:odd_job_app/jobs/geolocation/compute_distance.dart';
import 'package:odd_job_app/oddjob_colors.dart';

class JobCard extends StatelessWidget {
  
  late final Job job;
  late final user currentUser;
  final ComputeDistance computedDistance = ComputeDistance();
  final computeTime computedTime = computeTime();
  final OddJobColors myColors = new OddJobColors();
  final String cardBackground = '#1C2833';
  final String moneyText = '#2ECC71';
  late final Color cardBackgroundColor =
      Color(int.parse(cardBackground.substring(1, 7), radix: 16) + 0xFF000000);
  late final Color moneyTextColor =
      Color(int.parse(moneyText.substring(1, 7), radix: 16) + 0xFF000000);
  static ComputeDistance? _computedDistance;
  static user? _currentUser;

  JobCard({Key? key, required this.job, required this.currentUser})
      : super(key: key) {
    _computedDistance = ComputeDistance();
    _currentUser = currentUser;
  }

  static int sortByBid(JobCard a, JobCard b) {
    int cardA = int.parse(a.job.startingBid);
    int cardB = int.parse(b.job.startingBid);
    return -1 * cardA.compareTo(cardB);
  }

  static int sortByDistance(JobCard a, JobCard b) {
    if (_computedDistance == null || _currentUser == null) {
      // Handle the case when _computedDistance or _currentUser is not set
      return 0;
    }

    double distanceA = double.parse(_computedDistance!
        .compute(_currentUser!.currentLocation, a.job.longlat));
    double distanceB = double.parse(_computedDistance!
        .compute(_currentUser!.currentLocation, b.job.longlat));
    return distanceA.compareTo(distanceB);
  }

  static int sortByTime(JobCard a, JobCard b) {
    Timestamp local = Timestamp.now();
    Duration timeRemainingA =
        a.job.deadline.toDate().difference(local.toDate());
    Duration timeRemainingB =
        b.job.deadline.toDate().difference(local.toDate());
    return timeRemainingA.compareTo(timeRemainingB);
  }

// Add more cases as needed
  static IconData jobIcons(String jobName) {
    switch (jobName) {
      case 'Lawn Care':
        return Icons.grass;
      case 'Power Washing':
        return Icons.water_drop;
      case 'House Cleaning':
        return Icons.home;
      case 'Baby Sitting':
        return Icons.child_care;
      case 'Car Washing':
        return Icons.local_car_wash;
      case 'House Painting':
        return Icons.brush;
      case 'Tutoring':
        return Icons.school;
      case 'Moving Assistance':
        return Icons.local_shipping;
      case 'Pet Sitting':
        return Icons.pets;
      case 'Plumbing':
        return Icons.build;
      case 'Computer Repair':
        return Icons.computer;
      case 'Programming':
        return Icons.code;
      case 'Technology Services':
        return Icons.devices_other;
      case 'Graphic Design':
        return Icons.palette;
      case 'Car Repair':
        return Icons.build;
      case 'Other':
        return Icons.help;
      case 'Appliance Troubleshooting':
        return Icons.settings;
      case 'Woodworking':
        return Icons.collections;
      case 'Delivery':
        return Icons.delivery_dining;
      case 'Furniture Cleaning':
        return Icons.weekend;
      case 'Gardening':
        return Icons.eco;
      case 'Photography':
        return Icons.camera_alt;
      case 'Sewing and Alterations':
        return Icons.content_cut;
      case 'Organization':
        return Icons.dashboard;
      case 'Art':
        return Icons.palette;
      case 'Music':
        return Icons.music_note;
      case 'Pet Training':
        return Icons.pets;
      case 'Construction':
        return Icons.build;
      // Add more cases as needed
      default:
        return Icons.help; // Default icon if no match is found
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobDescriptionPage(jobID: job.ID),
        ),
      ),
      child: Card(
        elevation: 5,
        color: myColors.darkBlueColor,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      job.title,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: myColors.whittishColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Icon(
                    jobIcons(job.title),
                    color: myColors.whittishColor,
                    size: 30,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Current Bid',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: myColors.whittishColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '\$',
                        style: TextStyle(
                          color: moneyTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        job.startingBid,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: moneyTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${computedDistance.compute(currentUser.currentLocation, job.longlat)} miles',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    computedTime.compute(job.deadline),
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
