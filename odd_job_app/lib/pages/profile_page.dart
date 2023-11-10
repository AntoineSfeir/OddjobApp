import 'package:flutter/material.dart';
import 'package:odd_job_app/auth/main_page.dart';
import 'package:odd_job_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/job_history_page.dart';
import 'package:odd_job_app/pages/about_oddjob_page.dart';
import 'package:odd_job_app/pages/profile_info_page.dart';
import 'package:odd_job_app/pages/payment_option_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  int currentPageIndex = 3;

  final user = FirebaseAuth.instance.currentUser!;

  String? username;

  Future<void> getUsername() async {
    // get the current job's docIDs
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach((document) {
            if (document["email"] == user.email) {
              setState(() {
                username = document["username"];
              });
            } 
          }),
        );
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
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.15,
                        top: MediaQuery.of(context).size.height * 0.05,
                      ),
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue, // Blue circle
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
                          MaterialPageRoute(
                              builder: (context) => JobHistoryPage()),
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
