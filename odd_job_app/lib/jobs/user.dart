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
      jobsCompleted: data['jobsCompleted'] ?? 0,
      jobsPosted: data['jobsPosted'] ?? 0,
    );
  }
}
