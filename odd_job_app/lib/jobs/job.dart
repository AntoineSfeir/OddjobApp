import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/jobs/bid.dart';

class Job {
  late String description;
  late String title;
  late String startingBid;
  late GeoPoint longlat;
  late Timestamp deadline;
  late String address;
  late String ID;
  late String user;
  late String displayName;
  late String posterID;
  late List<bid> bids = [];
  //for Active Jobs
  late String working;
  late String contractorID;
  late String workerID;

  //use this constructor when testing
  Job({
    required this.description,
    required this.title,
    required this.startingBid,
    required this.deadline,
    required this.address,
    required this.longlat,
    required this.user,
    required this.displayName,
    required this.posterID,
  });

  //use this constructor when pulling from Firebase
  factory Job.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) {
      throw Exception("Document data is null");
    }

    return Job(
      description: data['description'] ?? '', // default value is the space
      title: data['title'] ?? '',
      startingBid: data['startingBid'] ?? '', // default value is the zero
      longlat: data['longlat'] ?? const GeoPoint(0, 0),
      deadline: data['deadline'] ?? Timestamp(0, 0),
      address: data['address'] ?? '',
      user: data['jobPoster'] ?? '',
      displayName: data['displayName'] ?? '',
      posterID: data['posterID'] ?? '',
    );
  }
}
