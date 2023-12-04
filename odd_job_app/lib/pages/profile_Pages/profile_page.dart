import 'dart:io';
import 'package:flutter/material.dart';
import 'package:odd_job_app/pages/jobs_Pages/post_job_page.dart';
import 'package:odd_job_app/jobAssets/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odd_job_app/auth/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/homePage_Pages/home_page2.dart';
import 'package:odd_job_app/pages/jobs_Pages/search_page.dart';
import 'package:odd_job_app/pages/chat_Pages/messages_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/profile_Pages/job_history_page.dart';
import 'package:odd_job_app/pages/profile_Pages/about_oddjob_page.dart';
import 'package:odd_job_app/pages/profile_Pages/profile_info_page.dart';
import 'package:odd_job_app/pages/profile_Pages/payment_option_page.dart';
import 'package:odd_job_app/pages/profile_Pages/manage_location_page.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

// ignore: unused_import

class ProfilePage extends StatefulWidget {
  final user currentUser;
  const ProfilePage({super.key, required this.currentUser});

  @override
  State<ProfilePage> createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  int currentPageIndex = 3;
  late final user thisUser;

  final AuthUser = FirebaseAuth.instance.currentUser!;
  late final String currentUserDocId;
  late File _image; // Variable to store the selected image

  @override
  void initState() {
    super.initState();
    thisUser = widget.currentUser; // Call the method in initState
  }


  String? avatarUrl;

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppBar(
                  backgroundColor: Colors.black,
                  title: const Text('Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                          centerTitle: true, // Center-align the title
                automaticallyImplyLeading: false, 
                ),
                // Profile Picture and Name
                
                Row(
                  children: [
                    GestureDetector( // Open image picker on tap
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.15,
                          top: MediaQuery.of(context).size.height * 0.05,
                        ),
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue, // Blue circle
                        ),
                        child: FutureBuilder<String?>(
                          future: getProfilePictureUrl(thisUser.ID),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError ||
                                snapshot.data == null) {
                              return const CircleAvatar(
                                backgroundColor: Color(0xFFC9D0D4),
                              );
                            } else {
                              return Center(
                                child: CircleAvatar(
                                  backgroundColor: const Color(0xFFC9D0D4),
                                  backgroundImage: NetworkImage(snapshot.data!),
                                  radius: 50,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    // Display username
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05,
                        top: MediaQuery.of(context).size.height * 0.05,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentUser.username,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                _ProfileInfoRow(
                    numOfJobsPosted: widget.currentUser.jobsPosted,
                    numOfJobsCompleted: widget.currentUser.jobsCompleted),
                // Divider
                Container(
                  height: 2,
                  color: Colors.grey,
                  margin:
                      EdgeInsets.symmetric(vertical: 10.0), // Adjusted margin
                ),
                // Options List
                const SizedBox(height: 10),
                // Manage Profile Information
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Adjust the factor as needed
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileInfoPage(currentUser: thisUser),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 12.0),
                      backgroundColor: Colors.white,
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.person,
                              size: 20, color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Profile Info',
                          style:
                              TextStyle(fontSize: 20, color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                // Job history
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Adjust the factor as needed
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const JobHistoryPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 12.0),
                      backgroundColor: Colors.white,
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Row(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(right: 8.0), // Added padding
                            child: Icon(Icons.history,
                                size: 20, color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Job History',
                            style: TextStyle(
                                fontSize: 20, color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                // Payment option
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Adjust the factor as needed
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentOptionsPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 12.0),
                      backgroundColor: Colors.white,
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Row(
                      children: <Widget>[
                        Icon(
                          Icons.payment,
                          size: 20,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        SizedBox(width: 12.0),
                        Text(
                          'Manage Payment Options',
                          style: TextStyle(
                            fontSize: 20,
                            color:  Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),
                // Manage Address Info
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Adjust the factor as needed
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ManageLocationInfoPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 12.0),
                      backgroundColor: Colors.white,
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Row(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(right: 8.0), // Added padding
                            child: Icon(Icons.location_pin,
                                size: 20, color:  Color.fromARGB(255, 0, 0, 0)),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Manage Location Settings',
                            style: TextStyle(
                                fontSize: 20, color:  Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                // About OddJob
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Adjust the factor as needed
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AboutOddJobPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 12.0),
                      backgroundColor: Colors.white,
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Row(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(right: 8.0), // Added padding
                            child: Icon(Icons.info,
                                size: 20, color:  Color.fromARGB(255, 0, 0, 0)),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'About OddJob',
                            style: TextStyle(
                              fontSize: 20,
                              color:  Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ],
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
                      }),
                  IconButton(
                    icon: const Icon(Icons.search),
                    color: Colors.white,
                    iconSize: 40.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SearchPage(currentUser: widget.currentUser)),
                      );
                    },
                  ),
                  Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.indigo,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        color: Colors.white,
                        iconSize: 35.0,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostJobPage(currentUser: widget.currentUser),
                            ),
                          );
                        },
                      ),
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
                      color: Colors.grey,
                      iconSize: 40.0,
                      onPressed: () {})
                ]),
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.numOfJobsPosted,
    required this.numOfJobsCompleted,
  });

  final int numOfJobsPosted;
  final int numOfJobsCompleted;

  @override
  Widget build(BuildContext context) {
    final List<ProfileInfoItem> items = [
      ProfileInfoItem("Jobs Posted", numOfJobsPosted),
      ProfileInfoItem("Jobs Completed", numOfJobsCompleted),
    ];

    return Container(
      margin: const EdgeInsets.all(15), // Set margin to zero
      child: SizedBox(
        height: null, // Set height to null to take available height
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var item in items) ...[
                  if (items.indexOf(item) != 0) const VerticalDivider(),
                  _singleItem(context, item),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: Colors.indigo, // Change the color as needed
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.value.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white, // Text color
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white, // Text color
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInfoItem {
  final String title;
  final int value;
  const ProfileInfoItem(this.title, this.value);
}
