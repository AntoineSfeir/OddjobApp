import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobDescriptionPage extends StatefulWidget {
  final String ID;
  const JobDescriptionPage({super.key, required this.ID});

  @override
  State<JobDescriptionPage> createState() => _JobDescriptionPageState();
}

class _JobDescriptionPageState extends State<JobDescriptionPage> {
  final db = FirebaseFirestore.instance;
  late Job thisJob;

  Future allJobs() async {
    widget.ID.trim();
    DocumentSnapshot<Map<String, dynamic>> doc =
        await db.collection('jobs/').doc(widget.ID).get();
    thisJob = Job.fromSnapshot(doc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('TEST'),
          backgroundColor: Colors.amber,
        ),
        body: FutureBuilder(
            future: allJobs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (thisJob != null) {
                  return Column(
                    children: <Widget>[Text(thisJob.title)],
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return const Text('Something went wrong');
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }
}
