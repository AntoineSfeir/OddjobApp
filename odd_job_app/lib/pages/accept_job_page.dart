import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/bid.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AcceptJobPage extends StatefulWidget {
  final bid thisBid;
  final Job theJob;
  AcceptJobPage({super.key, required this.thisBid, required this.theJob});

  @override
  State<AcceptJobPage> createState() => _AcceptJobPageState();
}

class _AcceptJobPageState extends State<AcceptJobPage> {
  late final bid finalBid;
  late final Job finalJob;
  late double tax;
  late double fee;
  late double total;
  bool calculated = false;

  @override
  void initState() {
    super.initState();
    finalBid = widget.thisBid;
    finalJob = widget.theJob;
    calculateCosts();
  }

  void calculateCosts() {
    tax = double.parse(finalBid.amount) * 0.0095;
    fee = double.parse(finalBid.amount) * 0.01;
    total = double.parse(finalBid.amount) + fee + tax;
    setState(() {
      calculated = true;
    });
  }

  Future removeJobFromBidsAddToActive() async {
    //removes all bids from each user file for this job
    for (int i = 0; i < finalJob.bids.length; i++) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(finalJob.bids[i].bidder.ID)
          .collection('currentBids')
          .doc(finalJob.bids[i].bidID)
          .delete();
    }
    String temp = '';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(finalJob.posterID)
        .collection('postedJobs')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              if (element['ID'] == finalJob.ID) {
                temp = element.id;
              }
            }));

    if (temp != '') {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(finalJob.posterID)
          .collection('postedJobs')
          .doc(temp)
          .delete();
    }

    //adds to active for the poster
    await FirebaseFirestore.instance
        .collection('users')
        .doc(finalJob.posterID)
        .collection('ActiveJobs')
        .add({
      'Working': 'false',
      'jobID': finalJob.ID,
      'workerID': finalBid.bidder.ID,
      'contractorID': finalJob.posterID,
    });
    print("ADDED TO ACTIVE ON ${finalJob.posterID}");
    //adds to active for the worker
    await FirebaseFirestore.instance
        .collection('users')
        .doc(finalBid.bidder.ID)
        .collection('ActiveJobs')
        .add({
      'Working': 'true',
      'jobID': finalJob.ID,
      'workerID': finalBid.bidder.ID,
      'contractorID': finalJob.posterID,
    });
    print("ADDED TO ACTIVE ON ${finalBid.bidder.ID}");

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const BidClosedPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Accept Job"),
      ),
      body: calculated
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      finalBid.jobThatWasBidOn.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                   _buildBigJobDescription(
                               finalBid.jobThatWasBidOn.description, ""),
                    const SizedBox(height: 12),
                    Text('Worker: ${finalBid.bidder.username}',
                    style: const TextStyle(
                       fontWeight: FontWeight.bold,
                        fontSize: 18,
                    ) ,),
                    const SizedBox(height: 12),
                    _buildRow("Bid Amount:", double.parse(finalBid.amount)),
                    const SizedBox(height: 12),
                    _buildRow("Cost:", double.parse(finalBid.amount)),
                    const SizedBox(height: 12),
                    _buildRow("Tax:", tax),
                    const SizedBox(height: 12),
                    _buildRow("Fee:", fee),
                    const SizedBox(height: 12),
                    _buildBigJobDescription("Total:", total.toStringAsFixed(2)),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          removeJobFromBidsAddToActive();
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                        ),
                        child: const Text('Finalize Bid'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Flexible(
            child: Container(
              child: Text(
                value.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


Widget _buildBigJobDescription(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}


  
}

class BidClosedPage extends StatelessWidget {
  const BidClosedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Close Bid',
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
            AnimatedCheckMark(),

            // Success Message
            SizedBox(height: 16),
            Text(
              'Biding is now closed for this job ',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 6),
            Text(
              'Your job is in progress!',
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
    );
  }
}

class AnimatedCheckMark extends StatefulWidget {
  const AnimatedCheckMark({super.key});

  @override
  _AnimatedCheckMarkState createState() => _AnimatedCheckMarkState();
}

class _AnimatedCheckMarkState extends State<AnimatedCheckMark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Opacity Animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    // Scale Animation
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    ));

    // Start the animation
    _controller.forward();
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
