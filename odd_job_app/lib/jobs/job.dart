import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  late String description;
  late String title;
  late String startingBid;
  late GeoPoint longlat;
  late Timestamp deadline;
  late String address;
  late String ID;

  Job({
    required this.description,
    required this.title,
    required this.startingBid,
    required this.deadline,
    required this.address,
    required this.longlat,
  });

  factory Job.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) {
      throw Exception("Document data is null");
    }

    return Job(
      description: data['description'] ?? '', // default value is the space
      title: data['title'] ?? '',
      startingBid: data['startingBid'] ?? '', // default value is the zero
      longlat: data['Description'] ?? const GeoPoint(0, 0),
      deadline: data['deadline'] ?? Timestamp(0, 0),
      address: data['address'] ?? '',
    );
  }
}
