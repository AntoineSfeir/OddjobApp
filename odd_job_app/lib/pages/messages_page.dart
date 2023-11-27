import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/chat_page.dart';
import 'package:odd_job_app/pages/home_page2.dart';
import 'package:odd_job_app/pages/search_page.dart';
import 'package:odd_job_app/chat/chat_service.dart';
import 'package:odd_job_app/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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
            backgroundColor: Colors.grey[300],
          appBar: AppBar(
            backgroundColor:
                Colors.black, // Set the same color as the bottom bar
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
            color: Colors.black,
            shape: const CircularNotchedRectangle(),
            child: SizedBox(
              height: 60.0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home),
                      color:  Colors.white,
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
                      color:  Colors.white,
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
                      color:  Colors.grey,
                      iconSize: 40.0,
                      onPressed: () {},
                    ),
                    IconButton(
                        icon: const Icon(Icons.person),
                        color:  Colors.white,
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
      String documentId = doc.reference.id;
      return ListTile(
        leading: FutureBuilder<String?>(
          future: getProfilePictureUrl(documentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // You can display a loading indicator here if needed
              return const CircularProgressIndicator();
            } else if (snapshot.hasError || snapshot.data == null) {
              return const CircleAvatar(
                backgroundColor: Color(0xFFC9D0D4),
              );
            } else {
              print(data['firstName']);
              return CircleAvatar(
                backgroundColor: const Color(0xFFC9D0D4),
                backgroundImage: NetworkImage(snapshot.data!),
              );
            }
          },
        ),
       title: Text(data['firstName'] + " " + data['lastName'],
       style: const TextStyle( fontSize: 20)),
        subtitle: FutureBuilder<String?>(
          future: _chatService.getMostRecentMessage(
            auth.currentUser!.email!,
            data['email'],
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...", overflow: TextOverflow.ellipsis);
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Text("Send a Message!", overflow: TextOverflow.ellipsis);
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
