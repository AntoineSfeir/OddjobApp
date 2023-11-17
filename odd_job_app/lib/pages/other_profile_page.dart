import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/job_history_page.dart';

class OtherProfilePage extends StatefulWidget {
  const OtherProfilePage({super.key, required this.recieverDocId});

  final String recieverDocId;

  @override
  State<OtherProfilePage> createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfilePage> {
  String? username;
  int? jobsPosted;
  int? jobsCompleted;

  Future<void> getProfileData() async {
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach((document) {
            if (document.reference.id == widget.recieverDocId) {
              setState(() {
                username = document["username"];
                jobsPosted = document["jobsPosted"];
                jobsCompleted = document["jobsCompleted"];
              });
            }
          }),
        );
  }

  String? comRating;
  String? workRating;
  String? hireAgainRating;

  Future<void> getProfileReviews() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.recieverDocId)
        .collection('reviews') // Assuming 'reviews' is the subcollection
        .get()
        .then(
          (snapshot) => snapshot.docs.forEach((document) {
            setState(() {
              comRating = document["communication"];
              workRating = document["workQuality"];
              hireAgainRating = document["wouldHireAgain"];
            });
          }),
        );
  }

  @override
  void initState() {
    super.initState();
    getProfileData();
    getProfileReviews(); // Call the method when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username ?? "Username"),
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
            const Expanded(flex: 1, child: _TopPortion()), // Reduced top space
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
                        FloatingActionButton.extended(
                          onPressed: () {},
                          heroTag: 'mesage',
                          elevation: 0,
                          backgroundColor: Colors.green,
                          label: const Text("Message"),
                          icon: const Icon(Icons.message_rounded),
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
                      numOfJobsPosted: jobsPosted ?? 0,
                      numOfJobsCompleted: jobsCompleted ?? 0,
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

                    _ProfileRatingsAndReviews(
                      communicationRating: comRating ?? "0",
                      workQualityRating: workRating ?? "0",
                      wouldHireAgainRating: hireAgainRating ?? "0",
                    ),

                    const SizedBox(height: 8.0),
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
                      child: const Text("View Job History"),
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
  const _TopPortion();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            'https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=1024x1024&w=is&k=20&c=-mUWsTSENkugJ3qs5covpaj-bhYpxXY-v9RDpzsw504=')),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _ProfileRatingsAndReviews extends StatelessWidget {
  final String communicationRating;
  final String workQualityRating;
  final String wouldHireAgainRating;

  const _ProfileRatingsAndReviews({
    required this.communicationRating,
    required this.workQualityRating,
    required this.wouldHireAgainRating,
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
            title: 'Communication',
            rating: communicationRating,
          ),
          const SizedBox(height: 8.0),
          _RatingCategory(
            title: 'Work Quality',
            rating: workQualityRating,
          ),
          const SizedBox(height: 8.0),
          _RatingCategory(
            title: 'Would Hire Again',
            rating: wouldHireAgainRating,
          ),
        ],
      ),
    );
  }
}

class _RatingCategory extends StatelessWidget {
  final String title;
  final String rating;

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
              rating,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStarIcon(BuildContext context, String rating) {
    // Replace this with your own logic to build star icons based on the rating
    // For simplicity, this example uses a filled star icon
    return const Icon(
      Icons.star,
      color: Colors.yellow,
      size: 20.0,
    );
  }
}
