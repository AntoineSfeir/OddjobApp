import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/jobcard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/home_page.dart';
import 'package:odd_job_app/pages/profile_page.dart';
import 'package:odd_job_app/pages/messages_page.dart';
import 'package:odd_job_app/jobs/post_job_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;

  List<String> docIDs = [];
  List<Job> jo = [];

  Future allJobs() async {
    await db
        .collection('jobs')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              Job i = Job.fromSnapshot(element);
              i.ID = element.id;
              jo.add(i);
            }));
    // final jobData = snapshot.docs.map((e) => Job.fromSnapshot(e)).toList();
    // jo = jobData;
  }

  final String cardBackground = '#1B475E';
  final String moneyText = '#8BD5FF';
  late final Color cardBackGroundColor =
      Color(int.parse(cardBackground.substring(1, 7), radix: 16) + 0xFF000000);
  late final Color moneyTextColor =
      Color(int.parse(moneyText.substring(1, 7), radix: 16) + 0xFF000000);

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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppBar(
                  title: const Text('Find a Job',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                Flexible(
                    child: ListView.builder(
                  // shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      future: allJobs(),
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (jo.isNotEmpty) {
                            return Column(
                              children:
                                  jo.map((Job) => JobCard(job: Job)).toList(),
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
                )),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.blue,
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
                            builder: (context) => const MessagesPage()),
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
                            builder: (context) => const ProfilePage()),
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
                MaterialPageRoute(builder: (context) => const PostJobPage()),
              );
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        ));
  }
}