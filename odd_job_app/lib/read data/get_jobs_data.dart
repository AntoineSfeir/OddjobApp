import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetJobTitle extends StatelessWidget {
  final String documentId;
  
  GetJobTitle({required this.documentId});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('jobs');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
           snapshot.data!.data() as Map<String, dynamic>;
          return Text(
            "${data['title']}",
          );
        }
        return Text(
          "Loading...",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        );
      })
       
    );
  }
}
