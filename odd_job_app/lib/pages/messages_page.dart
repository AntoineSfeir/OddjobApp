import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:odd_job_app/pages/chat_page.dart';
import 'package:odd_job_app/pages/home_page.dart';
import 'package:odd_job_app/pages/search_page.dart';
import 'package:odd_job_app/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/chat/chat_service.dart';

class MessagesPage extends StatefulWidget {
  final user currentUser;
  const MessagesPage({super.key, required this.currentUser});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            backgroundColor:
                Color(0xFF4F82A3), // Set the same color as the bottom bar
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchPage(
                                    currentUser: widget.currentUser,
                                  )),
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
        title: Text(data['firstName'] + " " + data['lastName']),
        subtitle: FutureBuilder<String?>(
          future: _chatService.getMostRecentMessage(
            auth.currentUser!.email!,
            data['email'],
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...", overflow: TextOverflow.ellipsis);
            } else if (snapshot.hasError || snapshot.data == null) {
              return Text("Send a Message!", overflow: TextOverflow.ellipsis);
            } else {
              return Text(snapshot.data!, overflow: TextOverflow.ellipsis);
            }
          },
        ),
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

  Future<String?> getProfilePictureUrl(String documentId) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref('profilePictures/$documentId.jpg');
      final result = await ref.getDownloadURL();
      return result;
    } catch (e) {
      // The file does not exist
      return null;
    }
  }
}
