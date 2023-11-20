import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetLocationWidget extends StatefulWidget {
  const GetLocationWidget({super.key});

  @override
  _GetLocationState createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocationWidget> {
  final Location location = Location();

  final user = FirebaseAuth.instance.currentUser!;
  String? currentUserDocId;
  Future<void> getUserDocId() async {
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach((document) {
            if (document["email"] == user.email) {
              setState(() {
                currentUserDocId = document.reference.id;
              });
            }
          }),
        );
  }

  @override
  void initState() {
    super.initState();
    getUserDocId();
  }

  bool _loading = false;

  LocationData? _location;
  String? _error;

  Future<void> _getLocation() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      String id = currentUserDocId ?? "";
      final locationResult = await location.getLocation();
      GeoPoint geoPoint =
          GeoPoint(locationResult.latitude!, locationResult.longitude!);
      await FirebaseFirestore.instance.collection('users').doc(id).set({
        'exactLocation': geoPoint,
      }, SetOptions(merge: true)).then(
          ((value) => print("User Location Updated")));
      setState(() {
        _location = locationResult;
        _loading = false;
      });
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Location: ${_error ?? '${_location ?? "unknown"}'}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Row(
          children: <Widget>[
            ElevatedButton(
              onPressed: _getLocation,
              child: _loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Get'),
            )
          ],
        ),
      ],
    );
  }
}
