import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/user.dart';

class BidPage extends StatefulWidget {
  final String stringBid;

  const BidPage({super.key, required this.stringBid, required this.jobID});
  final String jobID;
  @override
  State<BidPage> createState() => _BidPageState();
}

class _BidPageState extends State<BidPage> {
  late String userID;
  late String bidAmount;
  late int bid;
  final TextEditingController _controller = TextEditingController();
  final db = FirebaseFirestore.instance;
  List<user> users = [];
  final userEmail = FirebaseAuth.instance.currentUser!.email;

  Future getUsers() async {
    await db
        .collection('users')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              user i = user.fromSnapshot(element);
              i.ID = element.id;
              users.add(i);
            }));

    for (int i = 0; i < users.length; i++) {
      if (users[i].email == userEmail) {
        userID = users[i].ID;
      }
    }
  }

  Future updateBid() async {
    await getUsers();
    CollectionReference jobDoc = FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobID)
        .collection('currentBids');

    jobDoc
        .add({
          'userID': userID,
          'bidAmount': _controller.text.trim(),
        })
        .then((value) => print("job put in userPosted"))
        .catchError(
            (error) => print("Failed to put job in UserPoster: $error"));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    bid = int.parse(widget.stringBid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bids',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Bid:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$$bid',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your Bid',
                prefixText: '\$',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateBid,
                child: const Text('Bid Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
