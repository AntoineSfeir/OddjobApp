import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/chat_page.dart';
import 'package:odd_job_app/pages/home_page.dart';
import 'package:odd_job_app/pages/search_page.dart';
import 'package:odd_job_app/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            title: const Text(
              "Messages",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: buildUserList(),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SearchPage()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat),
                      color: Colors.white,
                      iconSize: 40.0,
                      onPressed: () {},
                    ),
                    IconButton(
                        icon: const Icon(Icons.person),
                        color: const Color.fromARGB(255, 238, 239, 239),
                        iconSize: 40.0,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfilePage()),
                          );
                        }),
                  ]),
            ),
          ),
        ));
  }

  Widget buildUserList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }
          return ListView(
            children: snapshot.data!.docs
                .map<Widget>((doc) => buildUserListItem(context, doc))
                .toList(),
          );
        });
  }

  Widget buildUserListItem(BuildContext context, DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    if (auth.currentUser!.email != data['email']) {
      return ListTile(
        title: Text(data['email']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                recieverEmail: data['email'],
                recieverUser: data['username'],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
