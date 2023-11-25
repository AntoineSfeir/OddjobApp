import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:odd_job_app/jobs/jobcard.dart';
import 'package:odd_job_app/pages/home_page2.dart';
import 'package:odd_job_app/jobs/post_job_page.dart';
import 'package:odd_job_app/pages/profile_page.dart';
import 'package:odd_job_app/pages/messages_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        backgroundColor: Colors.grey[200],
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              const SliverAppBar(
                expandedHeight: 55.0, // Set a fixed height
                floating: false,
                pinned: true,
                backgroundColor: Colors.indigo,
                title: Text(
                  'Find a Job',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ];
          },
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 4.0),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Type Here...',
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
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 16.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sorting Method',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            value: selectedOption,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedOption = newValue!;
                              });
                            },
                            items: <String>[
                              'Payment',
                              'Distance',
                              'Remaining Time'
                            ].map<DropdownMenuItem<String>>(
                              (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
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
                  childCount: 1,
                ),
              ),
            ],
          ),
        ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.indigo,
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
                              builder: (context) => const HomePage2()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: const Color.fromARGB(255, 238, 239, 239),
                      iconSize: 40.0,
                      onPressed: () {
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
                                  currentUser: widget.currentUser,
                                )),
                      );
                      },
                    ),
                    IconButton(
                        icon: const Icon(Icons.person),
                        color: const Color.fromARGB(255, 238, 239, 239),
                        iconSize: 40.0,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage(
                                      currentUser: widget.currentUser,
                                    )),
                          );
                        }),
                  ]),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) =>
          //               PostJobPage(currentUser: widget.currentUser)),
          //     );
          //   },
          //   backgroundColor: const Color(0xFF2598D7),
          //   child: const Icon(Icons.add),
          // ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        ));
  }
}
