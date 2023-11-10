import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:odd_job_app/auth/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/job_history_page.dart';
import 'package:odd_job_app/pages/about_oddjob_page.dart';
import 'package:odd_job_app/pages/profile_info_page.dart';
import 'package:odd_job_app/pages/payment_option_page.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  int currentPageIndex = 3;
  final user = FirebaseAuth.instance.currentUser!;
  String? username;
  String? currentUserDocId;
  File? _image; // Variable to store the selected image

  Future<void> getUsername() async {
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach((document) {
            if (document["email"] == user.email) {
              setState(() {
                username = document["username"];
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
          // Handle the case when the selected image is not a JPEG
          print('Unsupported image type: ${pickedFile.mimeType}');
          // You can display an error message or take other appropriate actions
        }
      }
    } catch (error) {
      // Handle other exceptions that might occur during image picking
      print('Error picking image: $error');
      // You can display an error message or take other appropriate actions
    }
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
      // Handle any unexpected errors during the upload process
      print('Error uploading image: $error');
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
      print('Error updating user profile: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getUsername(); // Call the method in initState
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  title: Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.blue,
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
                        child: ClipOval(
                          child: _image != null
                              ? Image.file(
                                  _image!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  avatarUrl ??
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKurFbiK1YFmGY6LV3FwBqui2WOp7Kx7Jk7A&usqp=CAU",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue, // Blue circle
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
                            username ?? "no name",
                            style: TextStyle(
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
                    top: MediaQuery.of(context).size.height * 0.05,
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
                          builder: (context) => ProfileInfoPage()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.person),
                        SizedBox(
                          width: 5,
                        ),
                        Text('Profile Info'),
                      ],
                    ),
                  ),
                ),

                // Job history
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JobHistoryPage()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.history),
                        SizedBox(
                          width: 5,
                        ),
                        Text('Job History'),
                      ],
                    ),
                  ),
                ),

                // Payment option
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentOptionsPage()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.payment),
                        SizedBox(
                          width: 5,
                        ),
                        Text('Payment Options'),
                      ],
                    ),
                  ),
                ),

                // About OddJob
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AboutOddJobPage()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.info),
                        SizedBox(
                          width: 5,
                        ),
                        Text('About OddJob'),
                      ],
                    ),
                  ),
                ),

                // logout button
                TextButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.logout),
                        SizedBox(
                          width: 5,
                        ),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                      color: Color.fromARGB(255, 248, 248, 248),
                      iconSize: 40.0,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }),
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
                      })
                ]),
          ),
        ),
      ),
    );
  }
}
