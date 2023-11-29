import 'package:flutter/material.dart';
import 'package:odd_job_app/jobAssets/user.dart';
import 'package:odd_job_app/auth/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileInfoPage extends StatefulWidget {
  final user currentUser;
  
  const ProfileInfoPage({super.key, required this.currentUser});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileInfoPageState createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
late final user thisUser;

  @override
  void initState() {
    super.initState();
    thisUser = widget.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            "Account Information",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
              },
            ),
          ],
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileInfoItem(title: "Username", value: thisUser.username),
              ProfileInfoItem(title: "First Name", value: thisUser.firstName),
              ProfileInfoItem(title: "Last Name", value: thisUser.lastName),
              ProfileInfoItem(title: "Date of Birth", value: thisUser.dob),
              ProfileInfoItem(title: "Address", value: thisUser.address),
              ProfileInfoItem(title: "City", value: thisUser.city),
              ProfileInfoItem(title: "State", value: thisUser.State),
              ProfileInfoItem(title: "Zip Code", value: thisUser.zip),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final String title;
  final String? value; // Use String? to allow for null values

  const ProfileInfoItem({super.key, 
    required this.title,
    this.value, // Make value optional
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value ??
                "N/A", // Use ?? to provide a default value if value is null
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const Divider(height: 20, color: Colors.grey),
        ],
      ),
    );
  }
}
