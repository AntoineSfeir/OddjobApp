import 'package:flutter/material.dart';
import 'package:odd_job_app/auth/main_page.dart';
import 'package:odd_job_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  
  int currentPageIndex = 3;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.32,
                    top: MediaQuery.of(context).size.height * 0.05,
                  ),
                  child: const Text(
                    'Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ),
                ),
                // Profile Picture and Name
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.15,
                        top: MediaQuery.of(context).size.height * 0.08,
                      ),
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue, // Blue circle
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05,
                        top: MediaQuery.of(context).size.height * 0.07,
                      ),
                      child: const Text(
                        'John Doe',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                // Divider
                Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0,
                    top: MediaQuery.of(context).size.height * 0.09,
                    right: MediaQuery.of(context).size.width * 0,
                  ),
                  height: 2,
                  color: (Colors.grey), // Divider color
                ),
                // Options List
                const SizedBox(height: 10),
                // const OptionItem(icon: Icons.location_on_outlined, text: 'Manage Address', ),
                // const OptionItem(icon: Icons.history, text: 'Order History'),
                // const OptionItem(icon: Icons.payment, text: 'Payment Options'),
                // const OptionItem(icon: Icons.info, text: 'About Oddjob'),
                // Logout Button
                // IconButton(
                //   icon: Icon(Icons.logout),
                //   tooltip: 'Logout',
                //   onPressed: () {
                //     FirebaseAuth.instance.signOut();
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => LoginPage),
                //     );
                //   },
                // )
                TextButton(
                  onPressed: (){
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
                        Icon(Icons.logout),
                        SizedBox(width: 5,),
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
    color: const Color.fromARGB(255, 132, 51, 218),
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
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }
                ),
                IconButton (
                  icon: const Icon(Icons.search),
                  color: const Color.fromARGB(255, 238, 239, 239),
                  iconSize: 40.0,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.chat),
                  color: Colors.white,
                  iconSize: 40.0,
                  onPressed: () {},
                ),
                IconButton (
                  icon: const Icon(Icons.person),
                  color: const Color.fromARGB(255, 238, 239, 239),
                  iconSize: 40.0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  }
                )
              ]
            ),
          ),
    ),

      ),
    );
  }
}

class OptionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressedCallback; // Define a callback parameter

  const OptionItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressedCallback, // Add the callback parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextButton(
        onPressed: onPressedCallback, // Call the provided callback function
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF395F75)),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: Color(0xFF1D465D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
