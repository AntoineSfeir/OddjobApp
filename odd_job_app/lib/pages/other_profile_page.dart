import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:odd_job_app/pages/chat_page.dart';
import 'package:odd_job_app/pages/job_history_page.dart';

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
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F83A2),
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
                child: _TopPortion(thisUser.username)), // Reduced top space
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
                          width: 190, // Adjusted width as needed
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
                            backgroundColor: Color(0xFF2598D7),
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
                        backgroundColor: const Color(
                            0xFF1D465D), // Set the desired background color
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

class _TopPortion extends StatelessWidget {
  _TopPortion(this.username);

  String username;

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
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      'https://imgs.search.brave.com/IqQs8kKNxjcbV_FjEBeZKiINN8kNBEh4ryKs5eF_V2I/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvMTMz/MjEwMDkxOS92ZWN0/b3IvbWFuLWljb24t/YmxhY2staWNvbi1w/ZXJzb24tc3ltYm9s/LmpwZz9zPTYxMng2/MTImdz0wJms9MjAm/Yz1BVlZKa3Z4UVFD/dUJoYXdIclVoRFJU/Q2VOUTNKZ3QwSzF0/WGpKc0Z5MWVnPQ',
                    ),
                  ),
                ),
              ),
            ),
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
        color: Colors.grey[200],
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
            rating: 7.5,//avgRating,
          ),
          const SizedBox(height: 8.0),
          _RatingCategory(
            title: 'Communication',
            rating: 5.6,//communicationRating,
          ),
          const SizedBox(height: 8.0),
          _RatingCategory(
            title: 'Work Quality',
            rating: 7.8,//workQualityRating,
          ),
          const SizedBox(height: 8.0),
          _RatingCategory(
            title: 'Would Hire Again',
            rating: 6.7,//wouldHireAgainRating,
          ),
          const SizedBox(height: 8.0),
          _RatingCategory(
            title: 'Trust Score',
            rating: 8.3,//trustScore,
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
    // Replace this with your own logic to build star icons based on the rating
    // For simplicity, this example uses a filled star icon
    return const Icon(
      Icons.star,
      color: Colors.yellow,
      size: 20.0,
    );
  }
}
