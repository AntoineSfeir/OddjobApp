import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({Key? key}) : super(key: key);

  @override
  _ProfileInfoPageState createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final user = FirebaseAuth.instance.currentUser!;

  String? username;
  String? firstName;
  String? lastName;
  String? dob;
  String? address;
  String? city;
  String? state;
  String? zip;
  
  Future<void> getUserData() async {
    // Check if user is not null before accessing its properties
    if (user.email != null) {
      // get the current job's docIDs
      await FirebaseFirestore.instance.collection('users').get().then(
            (snapshot) => snapshot.docs.forEach((document) {
              if (document["email"] == user.email) {
                print(document["email"]);
                setState(() {
                  username = document["username"];
                  firstName = document["firstName"];
                  lastName = document["lastName"];
                  dob = document["dob"];
                  address = document["address"];
                  city = document["city"];
                  state = document["state"];
                  zip = document["zip"];
                });
              }
            }),
          );
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData(); // Call the method in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          "Profile Information",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileInfoItem(title: "Username", value: username),
              ProfileInfoItem(title: "First Name", value: firstName),
              ProfileInfoItem(title: "Last Name", value: lastName),
              ProfileInfoItem(title: "Date of Birth", value: dob),
              ProfileInfoItem(title: "Address", value: address),
              ProfileInfoItem(title: "City", value: city),
              ProfileInfoItem(title: "State", value: state),
              ProfileInfoItem(title: "Zip Code", value: zip),
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

  const ProfileInfoItem({
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value ??
                "N/A", // Use ?? to provide a default value if value is null
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Divider(height: 20, color: Colors.grey),
        ],
      ),
    );
  }
}
