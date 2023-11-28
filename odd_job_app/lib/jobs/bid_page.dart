import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/home_page2.dart';


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

    CollectionReference userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('currentBids');

    userDoc
        .add({
          'jobID': widget.jobID,
          'bidAmount': _controller.text.trim(),
        })
        .then((value) => print("job put in userPosted"))
        .catchError(
            (error) => print("Failed to put job in UserPoster: $error"));

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const BidPostedSuccessfullyPage(),
    ));
  }

  @override
  void dispose() {
    super.dispose();
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
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
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
                child: const Text('Bid Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BidPostedSuccessfullyPage extends StatelessWidget {
  const BidPostedSuccessfullyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Bids',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Check Mark
            AnimatedCheckmark(),

            // Success Message
            SizedBox(height: 16),
            Text(
              'Your bid has been successfully placed!',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedCheckmark extends StatefulWidget {
  const AnimatedCheckmark({Key? key}) : super(key: key);

  @override
  _AnimatedCheckmarkState createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    ));

    _controller.forward();

    // Redirect to another page after 4 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage2()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}