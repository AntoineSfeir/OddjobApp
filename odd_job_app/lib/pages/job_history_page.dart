import 'package:flutter/material.dart';

class JobHistoryPage extends StatelessWidget {
  const JobHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Job History",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobHistoryItem(
              jobTitle: "Task 1",
              date: "January 10, 2023",
              status: "Completed",
            ),
            JobHistoryItem(
              jobTitle: "Task 2",
              date: "February 5, 2023",
              status: "In Progress",
            ),
            JobHistoryItem(
              jobTitle: "Task 3",
              date: "March 20, 2023",
              status: "Completed",
            ),
          ],
        ),
      ),
    );
  }
}

class JobHistoryItem extends StatelessWidget {
  final String jobTitle;
  final String date;
  final String status;

  const JobHistoryItem({
    required this.jobTitle,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          jobTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              "Date: $date",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Status: $status",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
