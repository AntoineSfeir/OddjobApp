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

  String selectedOption = 'Distance'; // Default option
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
          backgroundColor: Colors.grey[300],
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                const SliverAppBar(
                  expandedHeight: 55.0, // Set a fixed height
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.black,
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
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: TextStyle(color: Colors.black),
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Adjust the radius as needed
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchText = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PopupMenuButton<String>(
                            icon:
                                Icon(Icons.list, color: Colors.black, size: 30),
                            onSelected: (String newValue) {
                              setState(() {
                                selectedOption = newValue;
                              });
                            },
                            itemBuilder: (BuildContext context) {
                              return <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'Distance',
                                  child: Text('Distance'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'Payment',
                                  child: Text('Payment'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'Remaining Time',
                                  child: Text('Remaining Time'),
                                ),
                              ];
                            },
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
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (jo.isNotEmpty) {
                              List<JobCard> jobCards = filteredJobs()
                                  .map((job) => JobCard(
                                        job: job,
                                        currentUser: widget.currentUser,
                                      ))
                                  .toList();

                              if (selectedOption == 'Payment') {
                                jobCards
                                    .sort((a, b) => JobCard.sortByBid(a, b));
                              } else if (selectedOption == 'Distance') {
                                jobCards.sort(
                                    (a, b) => JobCard.sortByDistance(a, b));
                              } else {
                                jobCards
                                    .sort((a, b) => JobCard.sortByTime(a, b));
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
            color: Colors.black,
            shape: const CircularNotchedRectangle(),
            child: SizedBox(
              height: 60.0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home),
                      color: Colors.white,
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
                      color: Colors.white,
                      iconSize: 40.0,
                      onPressed: () {},
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
                        color: Colors.white,
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
        ));
  }
}
