import 'package:flutter/material.dart';
import 'package:odd_job_app/jobAssets/bid.dart';
import 'package:odd_job_app/jobAssets/job.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/homePage_Pages/home_page2.dart';
import 'package:odd_job_app/jobAssets/compute_time_to_display.dart';

class MyBidsViewTab extends StatefulWidget {
  final List<bid> myBids;
  const MyBidsViewTab({Key? key, required this.myBids}) : super(key: key);

  @override
  State<MyBidsViewTab> createState() => _MyBidsViewTabState();
}

class _MyBidsViewTabState extends State<MyBidsViewTab> {
  List<TextEditingController> _bidControllers = [];
  late final List<bid> myBids;
  computeTime computedTime = computeTime();

  @override
  void initState() {
    super.initState();
    myBids = widget.myBids;
    _bidControllers =
        List.generate(myBids.length, (index) => TextEditingController());
  }

  @override
  void dispose() {
    super.dispose();

    for (TextEditingController controller in _bidControllers) {
      controller.dispose();
    }
  }

  // Function to update the bid in Firestore
  Future changeBid(bid myBid, TextEditingController bidController) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(myBid.bidder.ID)
        .collection('currentBids')
        .doc(myBid.bidID)
        .set({
      'bidAmount': bidController.text.trim(),
      'jobID': myBid.jobThatWasBidOn.ID,
    });
    print("JOBID : ${myBid.jobThatWasBidOn.ID}");
    print("BIDAMOUNT : ${bidController.text.trim()}");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: ListView.builder(
          itemCount: myBids.length,
          itemBuilder: (context, index) {
            List<bid> bidsForJob = myBids;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 3,
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        myBids[index].jobThatWasBidOn.title,
                        style: const TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                      ),
                      Text(
                        computedTime
                            .compute(myBids[index].jobThatWasBidOn.deadline),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    'Winning Bid: \$${bidsForJob[index].amount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.indigo,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Job Description:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            myBids[index].jobThatWasBidOn.description,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const Divider(),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.monetization_on_outlined,
                                        color: Colors
                                            .green, // Set the desired color
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'My last Bid: \$${bidsForJob[index].amount}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical:
                                        8), // Adjust the left padding as needed
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _bidControllers[index],
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: 'Place a new bid',
                                        ),
                                        onTap: () {},
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        changeBid(bidsForJob[index],
                                            _bidControllers[index]);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomePage2()),
                                        );
                                        // Navigate to the accept job page
                                      },
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry>(
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                        ),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(
                                          const Size(100,
                                              36), // Adjust the size as needed
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.green),
                                      ),
                                      child: const Text('Change Bid'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
