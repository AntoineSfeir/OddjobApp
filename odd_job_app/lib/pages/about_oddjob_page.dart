import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutOddJobPage extends StatelessWidget {
  const AboutOddJobPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          "About OddJob",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to OddJob!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "About Us",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "OddJob is a platform connecting job seekers with various odd jobs and gig opportunities. Whether you need help with tasks or you're looking for a quick job, OddJob is here to help you find the right match.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Our Mission",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Our mission is to create a seamless and efficient platform that empowers individuals to find quick jobs and helps businesses and individuals find reliable help for their tasks and projects.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("Have questions or suggestions? Click below to email us!",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            MyClickableEmail(),
          ],
        ),
      ),
    );
  }
}

class MyClickableEmail extends StatelessWidget {
  final String emailAddress = "oddjobdeveloper@gmail.com";

  const MyClickableEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchEmail(),
      child: Text(
        emailAddress,
        style: const TextStyle(fontSize: 16, color: Colors.blue),
      ),
    );
  }

  _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {'subject': 'OddJob Inquiry'},
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch email';
    }
  }
}
