import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:odd_job_app/jobs/jobcard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/search_page.dart';
import 'package:odd_job_app/jobs/post_job_page.dart';
import 'package:odd_job_app/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/messages_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = FirebaseFirestore.instance;
  final userEmail = FirebaseAuth.instance.currentUser!.email;

  List<Job> allJobsInDB = [];
  List<Job> allActiveJobs = [];
  List<Job> allCurrentBids = [];
  List<Job> allPostedJobs = [];
  List<String> activeIDs = [];
  List<String> currentIDs = [];
  List<String> currentBidAmounts = [];
  List<String> postedIDs = [];
  List<String> docIDs = [];
  late Job thisJob;
  bool showPostedJobs = false;
  bool showCurrentBids = false;
  bool showActiveJobs = false;
  bool tryingShitOut = false;
  bool firstLoad = false;
  List<user> users = [];
  late user currentUser;

  Future sortJobs() async {
    // await db
    //     .collection('users')
    //     .doc(currentUser.ID)
    //     .collection('activeJobs')
    //     .get()
    //     .then((snapshot) => snapshot.docs.forEach((element) {
    //           activeIDs.add(element['ID']);
    //         }));

    await db
        .collection('users')
        .doc(currentUser.ID)
        .collection('currentBids')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              currentIDs.add(element['jobID']);
              currentBidAmounts.add(element['bidAmount']);
            }));

    await db
        .collection('users')
        .doc(currentUser.ID)
        .collection('postedJobs')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              postedIDs.add(element['ID']);
            }));
  }

  Future getCurrentUser() async {
    await db.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach((element) {
            user i = user.fromSnapshot(element);
            i.ID = element.id;
            users.add(i);
          }),
        );

    for (int i = 0; i < users.length; i++) {
      if (users[i].email == userEmail) {
        currentUser = users[i];
      }
    }
  }

  Future allJobs() async {
    if (!firstLoad) {
      await getCurrentUser();
      await db.collection('jobs').get().then(
            (snapshot) => snapshot.docs.forEach((element) {
              Job i = Job.fromSnapshot(element);
              i.ID = element.id;
              allJobsInDB.add(i);
            }),
          );
      firstLoad = true;
    }
  }

  Future getDocID() async {
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach((document) {
            docIDs.add(document.reference.id);
          }),
        );
  }

  @override
  void initState() {
    super.initState();

    getDocID();
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
            'HomePage',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: allJobs(),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (allJobsInDB.isNotEmpty) {
                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  showPostedJobs = !showPostedJobs;
                                });
                              },
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Current Bids'),
                                  Icon(Icons.arrow_downward),
                                ],
                              ),
                            ),
                            if (showPostedJobs)
                              Column(
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        tryingShitOut = !tryingShitOut;
                                      });
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('trying'),
                                        Icon(Icons.arrow_downward),
                                      ],
                                    ),
                                  ),
                                  // Add other buttons or UI elements related to "Posted Jobs" here
                                ],
                              ),
                            if (tryingShitOut)
                              Column(
                                children: allJobsInDB
                                    .map((Job) => JobCard(
                                          job: Job,
                                          currentUser: currentUser,
                                        ))
                                    .toList(),
                              ),
                            // ... other buttons and UI elements ...
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  showActiveJobs = !showActiveJobs;
                                });
                              },
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Active Jobs'),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                            ),
                            if (showActiveJobs)
                              Column(
                                children: allJobsInDB
                                    .map((Job) => JobCard(
                                          job: Job,
                                          currentUser: currentUser,
                                        ))
                                    .toList(),
                              ),
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  showCurrentBids = !showCurrentBids;
                                });
                              },
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Current Bids'),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                            ),
                            if (showCurrentBids)
                              Column(
                                children: allJobsInDB
                                    .map((Job) => JobCard(
                                          job: Job,
                                          currentUser: currentUser,
                                        ))
                                    .toList(),
                              ),
                          ],
                        ),
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
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  color: const Color.fromARGB(255, 238, 239, 239),
                  iconSize: 40.0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SearchPage(currentUser: currentUser),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat),
                  color: Colors.white,
                  iconSize: 40.0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MessagesPage(
                                currentUser: currentUser,
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
                          builder: (context) => ProfilePage(
                                currentUser: currentUser,
                              )),
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
              MaterialPageRoute(builder: (context) => PostJobPage(currentUser: currentUser)),
            );
          },
          backgroundColor: Color(0xFF2598D7),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }
}
