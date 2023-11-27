import 'package:flutter/material.dart';
//import 'package:google_maps/google_maps_visualization.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:odd_job_app/jobs/bid_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/other_profile_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odd_job_app/jobs/compute_time_to_display.dart';
import 'package:odd_job_app/jobs/geolocation/compute_distance.dart';
import 'package:odd_job_app/oddjob_colors.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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

  OddJobColors myColors = new OddJobColors();

  late int avgUserRating;

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
    thisUser.ID=userDoc.id;
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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: Colors.black,
        elevation: 0,
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
                      height: 200, // Adjusted height
                      //margin: const EdgeInsets.all(16),

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
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OtherProfilePage(recieverUser: thisUser),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(16.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: myColors.darkBlueColor,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            FutureBuilder<String?>(
                              future: getProfilePictureUrl(thisUser.ID), //fix this
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError ||
                                    snapshot.data == null) {
                                  return CircleAvatar(
                                    backgroundColor: Colors
                                        .grey,
                                    radius: 30.0, 
                                
                                  );
                                } else {
                                  return Center(
                                    child: CircleAvatar(
                                      backgroundColor: Colors
                                          .grey, 
                                      backgroundImage:
                                          NetworkImage(snapshot.data!),
                                      radius:
                                          30.0, // Adjust the radius as needed
                                      // You can customize other properties such as foregroundImage, etc.
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 10.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  thisJob.displayName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                buildStarRating(avgUserRating),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.all(16.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    thisJob.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Colors.black,
                              thickness: 1.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                thisJob.description,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            const Divider(
                              color: Colors.black,
                              thickness: 1.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Time Remaining: ${computedTime.compute(thisJob.deadline)}",
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Current Bid', // Concatenating '$' with the startingBid
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black, // Adjust the color
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '\$${thisJob.startingBid}', // Concatenating '$' with the startingBid
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black, // Adjust the color
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10.0),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BidPage(
                                    stringBid: thisJob.startingBid,
                                    jobID: thisJob.ID,
                                  ),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.indigo),
                              minimumSize: MaterialStateProperty.all<Size>(
                                const Size(
                                    200, 50), // Adjust the height as needed
                              ),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      25.0), // Adjust the radius
                                ),
                              ),
                            ),
                            child: const Text(
                              'Bid Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
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
          color: i < userRating ? Colors.amber : Colors.grey,
          size: 28, // Adjusted star size
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 15.0,
        top: 8.0, // Added top padding for spacing
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: stars,
      ),
    );
  }
}
