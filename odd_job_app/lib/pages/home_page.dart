import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/profile_page.dart';
import 'package:odd_job_app/pages/post_job_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/search_page.dart';
import 'package:odd_job_app/pages/job_title.dart';

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
            print(document.reference.toString());
            docIDs.add(document.reference.id);
          }),
        );
  }

  final String cardBackground = '#1B475E';
  final String moneyText = '#8BD5FF';
  late final Color cardBackGroundColor =
      Color(int.parse(cardBackground.substring(1, 7), radix: 16) + 0xFF000000);
  late final Color moneyTextColor =
      Color(int.parse(moneyText.substring(1, 7), radix: 16) + 0xFF000000);
  List<String> items = ['My Bids', 'Lawn Mowing', 'House Cleaning'];
  String? selectedItem = 'My Bids';
  List<String> items1 = ['My Jobs', 'Lawn Mowing', 'House Cleaning'];
  String? selectedJob = 'My Jobs';
  List<String> items2 = ['My Posted Jobs', 'Lawn Mowing', 'House Cleaning'];
  String? selectedPostedJob = 'My Posted Jobs';
  List<String> expan = ['Item 1', 'Item 2', 'Item 3'];
  List<bool> isExpanded = [
    false,
    false,
    false
  ]; // Keep track of expansion state

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('signed in as: ${user.email!}'),
            const Image(
              image: AssetImage('assets/ODDJOBLOGO.png'),
              width: 250,
              height: 150,
            ),
            const Divider(
              height: 25,
              color: Colors.black,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: expan.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: const Text("My Jobs"),
                  onExpansionChanged: (expanded) {
                    setState(
                      () {
                        isExpanded[index] = expanded;
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: cardBackGroundColor,
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
                //alignment: ,
                icon: const Icon(Icons.chat),
                color: Colors.white,
                iconSize: 40.0,
                onPressed: () {},
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
        backgroundColor: const Color(0xFF1D465D),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
