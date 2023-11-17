import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/search_page.dart';
import 'package:odd_job_app/pages/profile_page.dart';
import 'package:odd_job_app/pages/post_job_page.dart';
import 'package:odd_job_app/pages/messages_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  List<String> docIDs = [];

  Future getDocID() async {
    // get the current user's docIDs
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach((document) {
            docIDs.add(document.reference.id);
          }),
        );
  }

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
        appBar: AppBar(
          title: const Text(
            "Home",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            // Placeholder for Posted Jobs
            _buildJobSection("Posted Jobs", [
              "Job 1 - Posted",
              "Job 2 - Posted",
              "Job 3 - Posted",
            ]),
            // Divider for visual separation
            const Divider(
              height: 20,
              color: Colors.grey,
              thickness: 2,
            ),
            // Placeholder for Accepted Jobs
            _buildJobSection("Accepted Jobs", [
              "Job 1 - Accepted",
              "Job 2 - Accepted",
            ]),
            // Divider for visual separation
            const Divider(
              height: 20,
              color: Colors.grey,
              thickness: 2,
            ),
            // Placeholder for Overall Job Status
            _buildJobSection("Overall Job Status", [
              "Job 1 - In Progress",
              "Job 2 - Completed",
              "Job 3 - Pending",
            ]),
          ],
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
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  color: const Color.fromARGB(255, 238, 239, 239),
                  iconSize: 40.0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchPage()),
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
                      MaterialPageRoute(builder: (context) => const MessagesPage()),
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
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
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
      ),
    );
  }

  Widget _buildJobSection(String title, List<String> jobs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 150, // Adjust the height based on your content
          child: ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(jobs[index]),
                // Add more details or actions related to the job if needed
              );
            },
          ),
        ),
      ],
    );
  }
}
