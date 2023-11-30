import 'package:flutter/material.dart';
import 'package:odd_job_app/jobAssets/user.dart';
import 'package:odd_job_app/pages/chat_Pages/chat_page.dart';
import 'package:odd_job_app/pages/profile_Pages/job_history_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class OtherProfilePage extends StatefulWidget {
  final user recieverUser;
  const OtherProfilePage({super.key, required this.recieverUser});

  @override
  State<OtherProfilePage> createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfilePage> {
  String? username;
  int? jobsPosted;
  int? jobsCompleted;
  late user thisUser;

  Future<void> getProfileData() async {
    thisUser = widget.recieverUser;
    thisUser.averageRating = double.parse(((thisUser.trustScore +
                thisUser.workQuality +
                thisUser.communication +
                thisUser.wouldHireAgain) /
            4)
        .toStringAsFixed(1));
  }

  @override
  void initState() {
    super.initState();
    getProfileData(); // Call the method when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(thisUser.username),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: _TopPortion(
                    thisUser.username, thisUser.ID)), // Reduced top space
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Increased spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 160, // Adjusted width as needed
                          child: FloatingActionButton.extended(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    recieverEmail: thisUser.email,
                                    recieverUser: thisUser.username,
                                  ),
                                ),
                              );
                            },
                            heroTag: 'mesage',
                            elevation: 0,
                            backgroundColor: Colors.green,
                            label: const Text(
                              "Message",
                              style: TextStyle(
                                color:
                                    Colors.white, // Set the text color to white
                              ),
                            ),
                            icon: const Icon(Icons.message_rounded,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0,
                        top: MediaQuery.of(context).size.height * 0.02,
                        right: MediaQuery.of(context).size.width * 0,
                      ),
                      height: 2,
                      color: (Colors.grey), // Divider color
                    ),
                    const SizedBox(height: 16),
                    _ProfileInfoRow(
                      numOfJobsPosted: thisUser.jobsPosted,
                      numOfJobsCompleted: thisUser.jobsCompleted,
                    ),
                    // Divider
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0,
                        top: MediaQuery.of(context).size.height * 0.0001,
                        right: MediaQuery.of(context).size.width * 0,
                      ),
                      height: 2,
                      color: (Colors.grey), // Divider color
                    ),
                    const SizedBox(height: 16),
                    _ProfileRatingsAndReviews(
                      communicationRating: thisUser.communication,
                      workQualityRating: thisUser.workQuality,
                      wouldHireAgainRating: thisUser.wouldHireAgain,
                      trustScore: thisUser.trustScore,
                      avgRating: thisUser.averageRating,
                    ),

                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the job history page
                        // You need to replace 'JobHistoryPage' with the actual page you want to navigate to
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JobHistoryPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Set the desired background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20.0), // Adjusted border radius
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0), // Adjusted padding
                        child: Text(
                          "View Job History",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white, // Set the text color to white
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
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

class _TopPortion extends StatelessWidget {
  _TopPortion(this.username, this.id);

  String username;
  String id;

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          fit: StackFit.loose,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: FutureBuilder<String?>(
                future: getProfilePictureUrl(id), //fix this
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 50.0,
                    );
                  } else {
                    return Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(snapshot.data!),
                        radius: 50.0, // Adjust the radius as needed
                        // You can customize other properties such as foregroundImage, etc.
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ),
        const SizedBox(width: 16), // Adjust the spacing as needed
        Text(
          username,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ProfileRatingsAndReviews extends StatelessWidget {
  final double communicationRating;
  final double workQualityRating;
  final double wouldHireAgainRating;
  final double trustScore;
  final double avgRating;

  const _ProfileRatingsAndReviews({
    required this.communicationRating,
    required this.workQualityRating,
    required this.wouldHireAgainRating,
    required this.trustScore,
    required this.avgRating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.indigo[100],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ratings and Reviews',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          _RatingCategory(
            title: 'Overall Rating',
            rating: avgRating, //avgRating,
          ),
          const SizedBox(height: 8.0),
          _RatingCategory(
            title: 'Communication',
            rating: communicationRating, //communicationRating,
          ),
          const SizedBox(height: 8.0),
          _RatingCategory(
            title: 'Work Quality',
            rating: workQualityRating, //workQualityRating,
          ),
          const SizedBox(height: 8.0),
          _RatingCategory(
            title: 'Would Hire Again',
            rating: wouldHireAgainRating, //wouldHireAgainRating,
          ),
          const SizedBox(height: 8.0),
          _RatingCategory(
            title: 'Trust Score',
            rating: trustScore, //trustScore,
          ),
        ],
      ),
    );
  }
}

class _RatingCategory extends StatelessWidget {
  final String title;
  final double rating;

  const _RatingCategory({
    required this.title,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            _buildStarIcon(context, rating),
            const SizedBox(width: 4.0),
            Text(
              rating.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStarIcon(BuildContext context, double rating) {
    return const Icon(
      // Custom star icon, for example, using the FontAwesome icons
      FontAwesomeIcons.solidStar,
      color: Colors.yellow,
      size: 20.0,
    );
  }
}
