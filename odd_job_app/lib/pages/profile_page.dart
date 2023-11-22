import 'dart:io';
import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odd_job_app/auth/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/home_page2.dart';
import 'package:odd_job_app/pages/search_page.dart';
import 'package:odd_job_app/pages/messages_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/job_history_page.dart';
import 'package:odd_job_app/pages/about_oddjob_page.dart';
import 'package:odd_job_app/pages/profile_info_page.dart';
import 'package:odd_job_app/pages/payment_option_page.dart';
import 'package:odd_job_app/pages/manage_location_page.dart';
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

  final user = FirebaseAuth.instance.currentUser!;
  String? currentUserDocId;
  File? _image; // Variable to store the selected image

  Future<void> getUserDocId() async {
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach((document) {
            if (document["email"] == user.email) {
              setState(() {
                currentUserDocId = document.reference.id;
              });
            }
          }),
        );
  }

  // Function to open the image picker
  Future<void> _getImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Check if the image is of type JPEG
        if (pickedFile.mimeType == 'image/jpeg') {
          setState(() {
            _image = File(pickedFile.path);
          });

          // Upload the selected image
          await _uploadImage(_image!);
        } else {
          // Display an error message if the selected file is not of type JPEG
          // ignore: use_build_context_synchronously
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  content: Text('Please select a JPEG image'),
                );
              });
        }
      }
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      // Generate a unique filename for the image
      String fileName = '${DateTime.now()}.png';

      // Upload the image to Firebase Storage
      firebase_storage.Reference storageReference =
          firebase_storage.FirebaseStorage.instance.ref().child(fileName);

      await storageReference.putFile(imageFile);

      // Get the download URL of the uploaded image
      String imageUrl = await storageReference.getDownloadURL();

      // Update the user profile with the new avatar URL
      await updateProfileWithNewAvatar(imageUrl);
    } catch (error) {
      // Display an error message if there's an error
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(error.toString()),
            );
          });
    }
  }

  String? avatarUrl;
// Function to update user profile with the new avatar URL
  Future<void> updateProfileWithNewAvatar(String url) async {
    // Extract the avatar URL from the server response
    avatarUrl = url;
    try {
      // Update the user profile with the new avatar URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserDocId)
          .update({'avatarUrl': avatarUrl});
    } on FirebaseFirestore catch (e) {
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.toString()),
            );
          });
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

  @override
  void initState() {
    super.initState();
    getUserDocId(); // Call the method in initState
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.grey[200],
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  backgroundColor: const Color(0xFF4F82A3),
                  title: const Text('Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                // Profile Picture and Name
                Row(
                  children: [
                    GestureDetector(
                      onTap: _getImage, // Open image picker on tap
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
                          future: getProfilePictureUrl(currentUserDocId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Divider
                Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0,
                    top: MediaQuery.of(context).size.height * 0.02,
                    right: MediaQuery.of(context).size.width * 0,
                  ),
                  height: 2,
                  color: (Colors.grey), // Divider color
                ),

                _ProfileInfoRow(
                    numOfJobsPosted: widget.currentUser.jobsPosted,
                    numOfJobsCompleted: widget.currentUser.jobsCompleted),
                // Divider
                Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0,
                    top: MediaQuery.of(context).size.height * 0.009,
                    right: MediaQuery.of(context).size.width * 0,
                  ),
                  height: 2,
                  color: (Colors.grey), // Divider color
                ),
                // Options List
                const SizedBox(height: 10),
                // Manage Profile Information
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileInfoPage()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: const Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              right: 8.0), // Added padding
                          child: Icon(Icons.person,
                              size: 20, color: Color(0xFF2598D7)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Profile Info',
                          style:
                              TextStyle(fontSize: 20, color: Color(0xFF2598D7)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                // Job history
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const JobHistoryPage()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: const Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              right: 8.0), // Added padding
                          child: Icon(Icons.history,
                              size: 20, color: Color(0xFF2598D7)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Job History',
                          style:
                              TextStyle(fontSize: 20, color: Color(0xFF2598D7)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Payment option
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PaymentOptionsPage()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: const Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              right: 8.0), // Added padding
                          child: Icon(Icons.payment,
                              size: 20, color: Color(0xFF2598D7)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Manage Payment Options',
                          style:
                              TextStyle(fontSize: 20, color: Color(0xFF2598D7)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Manage Address Info
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageLocationInfoPage()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: const Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              right: 8.0), // Added padding
                          child: Icon(Icons.location_pin,
                              size: 20, color: Color(0xFF2598D7)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Manage Location Settings',
                          style:
                              TextStyle(fontSize: 20, color: Color(0xFF2598D7)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // About OddJob
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutOddJobPage()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: const Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              right: 8.0), // Added padding
                          child: Icon(Icons.info,
                              size: 20, color: Color(0xFF2598D7)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'About OddJob',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF2598D7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // logout button
                TextButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: const Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 8.0), // Added padding
                          child: Icon(Icons.logout,
                              size: 20, color: Color(0xFF2598D7)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF2598D7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF4F82A3),
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
                      }),
                  IconButton(
                    icon: const Icon(Icons.search),
                    color: const Color.fromARGB(255, 238, 239, 239),
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
          color: Colors.blue, // Change the color as needed
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
