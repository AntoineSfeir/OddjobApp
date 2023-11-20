import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AfterPostEditJobDescription extends StatefulWidget {
  const AfterPostEditJobDescription({Key? key}) : super(key: key);

  @override
  State<AfterPostEditJobDescription> createState() =>
      _AfterPostEditJobDescription();
}

class _AfterPostEditJobDescription extends State<AfterPostEditJobDescription> {
  final _jobDescriptionController = TextEditingController();
  final _jobDeadlineDateController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();

  @override
  void dispose() {
    _jobDescriptionController.dispose();
    _jobDeadlineDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          'Post a Job',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const Text("Edit your Job Description Here!"),
          TextFormField(
            controller: _jobDescriptionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter job description',
            ),
            maxLines: 11,
          ),
          const Text(
            'Deadline Date:',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            _selectedDate != null
                ? '${_selectedDate!.toLocal().month}-${_selectedDate!.toLocal().day}-${_selectedDate!.year}'
                : 'Select a date',
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
