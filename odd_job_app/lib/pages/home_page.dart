import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/profile_page.dart';
import 'package:odd_job_app/pages/post_job_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/read%20data/get_jobs_data.dart';
import 'package:odd_job_app/read%20data/get_user_data.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  List<String> docIDs = [];

  Future getDocID() async {
    // get the current job's docIDs
    await FirebaseFirestore.instance.collection('jobs').get().then(
          (snapshot) => snapshot.docs.forEach((document) {
            print(document.reference.toString());
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
    return Scaffold(
      appBar: AppBar(
        title: Text (
          user.email!,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FutureBuilder(
                future: getDocID(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: docIDs.length,
                    itemBuilder: (content, index) {
                      return ListTile(
                        title: GetJobTitle(documentId: docIDs[index]),
                      );
                    },
                  );
                },
              )
            )
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Color.fromARGB(255, 132, 51, 218),
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 60.0,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    color: Color.fromARGB(255, 248, 248, 248),
                    iconSize: 40.0,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    color: Color.fromARGB(255, 238, 239, 239),
                    iconSize: 40.0,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat),
                    color: Colors.white,
                    iconSize: 40.0,
                    onPressed: () {},
                  ),
                  IconButton(
                      icon: const Icon(Icons.person),
                      color: Color.fromARGB(255, 238, 239, 239),
                      iconSize: 40.0,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()),
                        );
                      }),
                       const SizedBox(width: 40.0),
                ]
              ),

          ),
          
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
                   Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostJobPage()),
                        );
          },
          backgroundColor: const Color(0xFF1D465D),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      );
  }
}
