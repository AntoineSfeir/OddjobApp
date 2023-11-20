import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:odd_job_app/jobs/bid_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/other_profile_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odd_job_app/jobs/compute_time_to_display.dart';
import 'package:odd_job_app/jobs/geolocation/compute_distance.dart';

class JobDescriptionPage extends StatefulWidget {
  final String ID;
  // ignore: non_constant_identifier_names
  const JobDescriptionPage({super.key, required this.ID});

  @override
  State<JobDescriptionPage> createState() => _JobDescriptionPageState();
}

class _JobDescriptionPageState extends State<JobDescriptionPage> {
  ComputeDistance computedDistance = ComputeDistance();
  computeTime computedTime = computeTime();
  final Set<Marker> _markers = {};
  final db = FirebaseFirestore.instance;
  late Job thisJob;
  late user thisUser;
  late GoogleMapController _mapController;
  late LatLng l;
  late String userDocId;

  late int avgUserRating;

  Future<void> allJobs() async {
    widget.ID.trim();
    print('jobs/${widget.ID}');
    DocumentSnapshot<Map<String, dynamic>> doc =
        await db.collection('jobs/').doc(widget.ID).get();
    thisJob = Job.fromSnapshot(doc);
    thisJob.ID = doc.id;
    l = LatLng(thisJob.longlat.latitude, thisJob.longlat.longitude);

    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await db.collection('users/').doc(thisJob.posterID).get();

    thisUser = user.fromSnapshot(userDoc);
    avgUserRating = thisUser.averageRating.toInt();
  }

  @override
  void initState() {
    super.initState();

    allJobs(); // Call the method in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: Colors.amber,
        elevation: 0, // Remove app bar shadow
      ),
      body: FutureBuilder(
        future: allJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (thisJob != null) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 165, // Adjusted height
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: l, zoom: 18),
                        mapType: MapType.normal,
                        myLocationButtonEnabled: true,
                        compassEnabled: true,
                        markers: _markers,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                          _markers.add(Marker(
                            markerId: const MarkerId('jobMarker'),
                            visible: true,
                            position: l,
                            infoWindow: InfoWindow(
                              title:
                                  '${computedDistance.compute(thisJob.longlat, thisJob.longlat).toString()} miles',
                            ),
                          ));
                          _mapController.animateCamera(
                            CameraUpdate.newLatLng(l),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OtherProfilePage(recieverUser: thisUser),
                            ),
                          );
                        },
                        child: Text(
                          thisJob.displayName,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    buildStarRating(avgUserRating),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          "${(avgUserRating/2).round()}/5 stars based on ${5} ratings",
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Expires in " + computedTime.compute(thisJob.deadline),
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // Increased spacing
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            thisJob.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Divider(
                            color: Colors.black,
                            thickness: 1.0,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            thisJob.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16), // Increased spacing
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Current Bid: ${thisJob.startingBid}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0, // Adjusted font size
                            ),
                          ),
                          const SizedBox(height: 16.0), // Increased spacing
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    20.0), // Adjusted border radius
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(12.0), // Adjusted padding
                              child: Text(
                                "Bid Now",
                                style: TextStyle(
                                    fontSize: 18.0), // Adjusted font size
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BidPage(
                                        stringBid: thisJob.startingBid,
                                        jobID: thisJob.ID)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return const Text('Something went wrong');
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget buildStarRating(int userRating) {
    List<Icon> stars = [];
    userRating = (userRating / 2).round();

    for (int i = 0; i < 5; i++) {
      stars.add(
        Icon(
          Icons.star,
          color: i < userRating ? Colors.yellow : Colors.grey,
        ),
      );
    }

    return Row(
      children: stars,
    );
  }
}
