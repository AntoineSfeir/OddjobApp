import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class PostJobPage extends StatefulWidget {
  const PostJobPage({Key? key}) : super(key: key);

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final _jobTitleController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _startingBidController = TextEditingController();

  DateTime? _selectedDate = DateTime.now();

  @override
  void dispose() {
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _startingBidController.dispose();
    super.dispose();
  }

  // Post job to database
  Future postJob() async {
    addJobDetails(_jobTitleController.text, _jobDescriptionController.text,
        _startingBidController.text, _selectedDate!);
  }

  // Add job details to database
  Future addJobDetails(String title, String description, String startingBid,
      DateTime date) async {
    CollectionReference jobs = FirebaseFirestore.instance.collection('jobs');
    return jobs
        .add({
          'title': title,
          'description': description,
          'startingbid': startingBid,
          'deadlinedate': date,
        })
        .then((value) => print("Job posted"))
        .catchError((error) => print("Failed to post job: $error"));
  }

 // Select date deadline
 Future<void> _selectDeadLineDate(BuildContext context) async {
  final DateTime currentDate = DateTime.now();
  final DateTime twoMonthsFuture = currentDate.add(Duration(days: 60)); // 60 days in the future

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: currentDate, // Set initialDate to today
    firstDate: currentDate, // Set firstDate to today
    lastDate: twoMonthsFuture, // Set lastDate to 2 months in the future
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[300],
    appBar: AppBar(
      title: Text('Post a Job'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Job Title:',
            style: TextStyle(fontSize: 18),
          ),
          TextFormField(
            controller: _jobTitleController,
            decoration: InputDecoration(
              hintText: 'Enter job title',
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Job Description:',
            style: TextStyle(fontSize: 18),
          ),
          TextFormField(
            controller: _jobDescriptionController,
            decoration: InputDecoration(
              hintText: 'Enter job description',
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Starting Bid:',
            style: TextStyle(fontSize: 18),
          ),
          TextFormField(
            controller: _startingBidController,
            decoration: InputDecoration(
              hintText: 'Enter starting bid',
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Deadline Date:',
            style: TextStyle(fontSize: 18),
          ),
          Row(
            children: <Widget>[
              Text(
                _selectedDate != null
                    ? '${_selectedDate!.toLocal()}'
                    : 'Select a date',
              ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  await _selectDeadLineDate(context);
                  setState(() {});
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: postJob,
            child: Text('Post Job'),
          ),
        ],
      ),
    ),
  );
}

}
