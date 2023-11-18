import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:flutter_google_maps_webservices/places.dart';
import 'package:odd_job_app/jobs/geolocation/auto_complete_prediction.dart';
import 'package:odd_job_app/jobs/geolocation/location_list_tile.dart';
import 'package:odd_job_app/jobs/geolocation/network_utility.dart';
import 'package:odd_job_app/jobs/geolocation/place_auto_complete_response.dart';

class SearchLocationScreen extends StatefulWidget {
  final Function(LatLng, String) onVariableChanged;
  const SearchLocationScreen({Key? key, required this.onVariableChanged})
      : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  List<AutocompletePreds> placePredictions = [];
  Set<Marker> _markers = {};
  TextEditingController locationController = TextEditingController();
  FocusNode locationFocus = FocusNode();

  void placeAutocomplete(String query) async {
    Uri uri =
        Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
      "input": query,
      "key": "AIzaSyAAmjXS8SixvRBgORhdaGyvdoOVhXJkd84",
    });
    String? response = await NetworkUtility().fetchUrl(uri);

    if (response != null) {
      PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if (result.predictions != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }

  Future<List<Location>> locationFromAddress(
    String address, {
    String? localeIdentifier,
  }) async =>
      GeocodingPlatform.instance.locationFromAddress(
        address,
        localeIdentifier: localeIdentifier,
      );

  List<Location> location = [];
  LatLng addressLoc = LatLng(0, 0);
  String addressAddress = '';
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController? _mapController;

  Future<void> initializeLocation(String address) async {
    location = await locationFromAddress(address);
    updateMapCamera(location[0].latitude, location[0].longitude);
    addressLoc = LatLng(location[0].latitude, location[0].longitude);
    addressAddress = address;
  }

  void updateMapCamera(double latitude, double longitude) {
    if (_mapController != null) {
      print('About to animate camera');
      _mapController!
          .animateCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)))
          .then((_) {
        print('Map camera animation completed');

        _markers = {
          Marker(
            markerId: MarkerId('chosenLocation'),
            position: LatLng(latitude, longitude),
          ),
        };
        setState(() {});
      }).catchError((error) {
        print('Error during map camera animation: $error');
      });
    } else {
      // This print statement will help you determine if this block is being executed
      print('Map controller is null. Cannot update camera.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Set Job Location",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 100,
              child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(30.3997505, -91.1715959), zoom: 10),
                  mapType: MapType.normal,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    _mapController = controller;
                  }),
            ),
            Form(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: locationController,
                    focusNode: locationFocus,
                    onChanged: (value) {
                      placeAutocomplete(value);
                    },
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                        hintText: "Search your location",
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        )),
                  )),
            ),
            const Divider(height: 4, thickness: 4, color: Colors.black),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (locationController.text.isEmpty) {
                    //THROW AN ERROR
                  } else {
                    widget.onVariableChanged(addressLoc, addressAddress);
                  }
                },
                icon: Icon(Icons.house),
                label: const Text("Use This Location"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  fixedSize: const Size(double.infinity, 40),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
            const Divider(
              height: 4,
              thickness: 4,
              color: Colors.grey,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: placePredictions.length,
                itemBuilder: (context, index) => LocationListTile(
                  press: () {
                    print('BEFORE INITIALIZE');
                    initializeLocation(placePredictions[index].description!);
                    locationController.text =
                        placePredictions[index].description!;
                    locationFocus.unfocus();
                    print('AFTER INITIALIZE');
                    print('BEFORE UPDATE');

                    print('AFTER UPDATE');
                  },
                  location: placePredictions[index].description!,
                ),
              ),
            ),
          ],
        ));
  }
}








// class AddressPage extends StatefulWidget {
//   const AddressPage({super.key});

//   @override
//   State<AddressPage> createState() => _AddressPageState();
// }

// class _AddressPageState extends State<AddressPage> {
//   late GoogleMapController mapController;
//   late String searchAddress;

//   Completer<GoogleMapController> _controller = Completer();
//   List<Marker> _marker = [];
//   final List<Marker> _list = const [
//     Marker(
//       markerId: MarkerId('1'),
//       position: LatLng(30.3997505, -91.1715959),
//       infoWindow: InfoWindow(
//         title: "My current location",
//       ),
//     )
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _marker.addAll(_list);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Enter Your Address Here"),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//       child: GoogleMap(
//           initialCameraPosition: CameraPosition(
//             target: LatLng(30.3997505, -91.1715959),
//           ),
//           mapType: MapType.normal,
//           myLocationButtonEnabled: true,
//           compassEnabled: true,
//           markers: Set<Marker>.of(_marker),
//           onMapCreated: (GoogleMapController controller) {
//             _controller.complete(controller);
//           }),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child
//       ),
//     );
//   }
// }
