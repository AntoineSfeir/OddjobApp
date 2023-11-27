import 'package:cloud_firestore/cloud_firestore.dart';

class user {
  late String address;
  late String city;
  late String dob;
  late String email;
  late String firstName;
  late String lastName;
  late String State;
  late String username;
  late String zip;
  late String ID;
  late int jobsPosted;
  late int jobsCompleted;
  late GeoPoint currentLocation;
  late double communication;
  late double workQuality;
  late double wouldHireAgain;
  late double trustScore;
  late double averageRating;
  late List<String> dontShow;

  user({
    required this.address,
    required this.city,
    required this.dob,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.State,
    required this.username,
    required this.zip,
    required this.jobsCompleted,
    required this.jobsPosted,
    required this.currentLocation,
    required this.communication,
    required this.workQuality,
    required this.wouldHireAgain,
    required this.trustScore,
    required this.averageRating,
  });

  factory user.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) {
      throw Exception("Document data is null");
    }

    return user(
      address: data['address'] ?? '', // default value is the space
      city: data['city'] ?? '',
      dob: data['dob'] ?? '', // default value is the zero
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      State: data['state'] ?? '',
      username: data['username'] ?? '',
      zip: data['zip'] ?? '',
      jobsCompleted: data['totalCompletedJobs'] ?? 0,
      jobsPosted: data['totalPostedJobs'] ?? 0,
      communication: data['communication'] ?? 0.0,
      workQuality: data['workQuality'] ?? 0.0,
      wouldHireAgain: data['wouldHireAgain'] ?? 0.0,
      trustScore: data['trustScore'] ?? 0.0,
      averageRating: data['averageRating'] ?? 0.0,
      currentLocation: data['exactLocation'] ?? const GeoPoint(0, 0),
    );
  }
}
