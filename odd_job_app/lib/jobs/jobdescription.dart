import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/jobs/job.dart';
=======
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odd_job_app/jobs/checkout.dart';
import 'package:odd_job_app/jobs/compute_time_to_display.dart';
import 'package:odd_job_app/jobs/geolocation/compute_distance.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/jobs/user.dart';
>>>>>>> Stashed changes

class JobDescriptionPage extends StatefulWidget {
  final String ID;
  const JobDescriptionPage({Key? key, required this.ID}) : super(key: key);

  @override
  State<JobDescriptionPage> createState() => _JobDescriptionPageState();
}

class _JobDescriptionPageState extends State<JobDescriptionPage> {
  ComputeDistance computedDistance = ComputeDistance();
  computeTime computedTime = computeTime();
  Set<Marker> _markers = {};
  final db = FirebaseFirestore.instance;
  late Job thisJob;
  late GoogleMapController _mapController;
  late LatLng l;

<<<<<<< Updated upstream
  Future allJobs() async {
    print(widget.ID);
=======
  Future<void> allJobs() async {
>>>>>>> Stashed changes
    widget.ID.trim();
    print('jobs/${widget.ID}');
    DocumentSnapshot<Map<String, dynamic>> doc =
        await db.collection('jobs/').doc(widget.ID).get();
    thisJob = Job.fromSnapshot(doc);
    l = LatLng(thisJob.longlat.latitude, thisJob.longlat.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< Updated upstream
        appBar: AppBar(
          title: Text('TEST'),
          backgroundColor: Colors.amber,
        ),
        body: FutureBuilder(
            future: allJobs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (thisJob != null) {
                  return Column(
                    children: <Widget>[Text(thisJob.title)],
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
            }));
=======
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
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: Offset(0, 3),
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
                            markerId: MarkerId('jobMarker'),
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
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        thisJob.displayName,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.star, color: Colors.yellow),
                          Icon(Icons.star, color: Colors.yellow),
                          Icon(Icons.star, color: Colors.yellow),
                          Icon(Icons.star, color: Colors.yellow),
                          Icon(Icons.star, color: Colors.yellow),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "5/5 stars based on 5 ratings",
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Expires in " + computedTime.compute(thisJob.deadline),
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // Increased spacing
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      padding: EdgeInsets.all(16.0),
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Divider(
                            color: Colors.black,
                            thickness: 1.0,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            thisJob.description,
                            style: TextStyle(
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
                            style: TextStyle(
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
                                    builder: (context) => CheckOut(
                                        stringBid: thisJob.startingBid)),
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
>>>>>>> Stashed changes
  }
}
