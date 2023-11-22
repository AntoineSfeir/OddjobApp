import 'package:flutter/material.dart';

class JobHistoryPage extends StatelessWidget {
  const JobHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
         backgroundColor: Colors.indigo,
        title: const Text(
          "Job History",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
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

  const JobHistoryItem({super.key, 
    required this.jobTitle,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          jobTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "Date: $date",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Status: $status",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
