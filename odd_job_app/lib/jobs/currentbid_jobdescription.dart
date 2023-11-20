import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odd_job_app/jobs/bid.dart';
import 'package:odd_job_app/jobs/bid_page.dart';
import 'package:odd_job_app/jobs/compute_time_to_display.dart';
import 'package:odd_job_app/jobs/geolocation/compute_distance.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:odd_job_app/pages/other_profile_page.dart';

class CurrentBidJobDescription extends StatefulWidget {
  final bid thisBid;

  const CurrentBidJobDescription({Key? key, required this.thisBid})
      : super(key: key);

  @override
  State<CurrentBidJobDescription> createState() => _CurrentBidJobDescription();
}

class _CurrentBidJobDescription extends State<CurrentBidJobDescription> {
  ComputeDistance computedDistance = ComputeDistance();
  computeTime computedTime = computeTime();
  final Set<Marker> _markers = {};
  final db = FirebaseFirestore.instance;
  late Job thisJob;
  late user thisUser;
  late GoogleMapController _mapController;
  late LatLng l;
  late String userDocId;
  final bidController = TextEditingController();
  late bid thisBid;

  Future<void> allJobs() async {
    thisBid = widget.thisBid;
    thisJob = thisBid.jobThatWasBidOn;
    l = LatLng(thisJob.longlat.latitude, thisJob.longlat.longitude);
  }

  void dispose() {
    bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posted Job Details'),
        backgroundColor: Colors.amber,
        elevation: 0, // Remove app bar shadow
      ),
      body: FutureBuilder(
        future: allJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 165,
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
                    child: Expanded(
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
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Current Bid: ${thisJob.startingBid}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  "Cancel Bid",
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ),
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
                            ),
                            SizedBox(width: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Change Your Bid',
                              ),
                              controller: bidController,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
