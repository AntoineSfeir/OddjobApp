import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:odd_job_app/jobs/jobcard.dart';
import 'package:odd_job_app/jobs/jobcard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/home_page.dart';
import 'package:odd_job_app/jobs/post_job_page.dart';
import 'package:odd_job_app/pages/profile_page.dart';
import 'package:odd_job_app/pages/messages_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/jobs/jobdescription.dart';

class SearchPage extends StatefulWidget {
  final user currentUser;
  const SearchPage({super.key, required this.currentUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final db = FirebaseFirestore.instance;

  bool firstAllJOB = false;
  List<String> docIDs = [];
  List<Job> jo = [];

  Future allJobs() async {
    if (!firstAllJOB) {
      await db
          .collection('jobs')
          .get()
          .then((snapshot) => snapshot.docs.forEach((element) {
                Job i = Job.fromSnapshot(element);
                i.ID = element.id;
                jo.add(i);
              }));
      firstAllJOB = true;
    }
    // final jobData = snapshot.docs.map((e) => Job.fromSnapshot(e)).toList();
    // jo = jobData;
  }

  List<Job> filteredJobs() {
  if (searchText.isEmpty) {
    return jo;
  }
  return jo.where((job) {
    return job.title.toLowerCase().contains(searchText.toLowerCase());
  }).toList();
}

  final String cardBackground = '#1B475E';
  final String moneyText = '#8BD5FF';
  late final Color cardBackGroundColor =
      Color(int.parse(cardBackground.substring(1, 7), radix: 16) + 0xFF000000);
  late final Color moneyTextColor =
      Color(int.parse(moneyText.substring(1, 7), radix: 16) + 0xFF000000);

  String selectedOption = 'Payment'; // Default option
  String searchText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFFF8FBFD),
          appBar: AppBar(
            backgroundColor: Color(0xFF4F82A3),
            title: const Text(
              'Find a Job',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  color: Color(0xFF4F83A2),
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8.0),
                      DropdownButton<String>(
                        value: selectedOption,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedOption = newValue!;
                            // You can update the job list based on the selected option
                          });
                        },
                        items: <String>['Payment', 'Distance', 'Remaining Time']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      future: allJobs(),
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (jo.isNotEmpty) {
                            List<JobCard> jobCards = filteredJobs()
                                .map((job) => JobCard(
                                      job: job,
                                      currentUser: widget.currentUser,
                                    ))
                                .toList();

                            //in this section, check selectedOption to see how we sort it
                            if (selectedOption == 'Payment') {
                              jobCards.sort((a, b) => JobCard.sortByBid(a, b));
                            } else if (selectedOption == 'Distance') {
                              jobCards
                                  .sort((a, b) => JobCard.sortByDistance(a, b));
                            } else {
                              jobCards.sort((a, b) => JobCard.sortByTime(a, b));
                            }

                            return Column(
                              children: jobCards,
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
                      }),
                    );
                  },
                  itemCount: 1,
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: Color(0xFF4F82A3),
            shape: const CircularNotchedRectangle(),
            child: SizedBox(
              height: 60.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    color: const Color.fromARGB(255, 248, 248, 248),
                    iconSize: 40.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    color: const Color.fromARGB(255, 238, 239, 239),
                    iconSize: 40.0,
                    onPressed: () {},
                  ),
                  IconButton(
                    //alignment: ,
                    icon: const Icon(Icons.chat),
                    color: Colors.white,
                    iconSize: 40.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MessagesPage(
                                  currentUser: widget.currentUser,
                                )),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.person),
                    color: Colors.white,
                    iconSize: 40.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(currentUser: widget.currentUser)),
                      );
                    },
                  ),
                  const SizedBox(width: 40.0),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PostJobPage(currentUser: widget.currentUser)),
              );
            },
            backgroundColor: Color(0xFF2598D7),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        ));
  }
}
