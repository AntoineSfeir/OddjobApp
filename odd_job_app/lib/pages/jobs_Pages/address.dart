import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odd_job_app/jobAssets/geolocation/network_utility.dart';
import 'package:odd_job_app/jobAssets/geolocation/location_list_tile.dart';
import 'package:odd_job_app/jobAssets/geolocation/auto_complete_prediction.dart';
import 'package:odd_job_app/jobAssets/geolocation/place_auto_complete_response.dart';
//import 'package:flutter_google_maps_webservices/places.dart';

class SearchLocationScreen extends StatefulWidget {
  final Function(LatLng, String) onVariableChanged;
  const SearchLocationScreen({super.key, required this.onVariableChanged});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  
  List<AutocompletePreds> placePredictions = [];
  Set<Marker> _markers = {};
  TextEditingController locationController = TextEditingController();
  FocusNode locationFocus = FocusNode();
  List<Location> location = [];
  LatLng addressLoc = const LatLng(0, 0);
  String addressAddress = '';
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController? _mapController;

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

  Future<void> initializeLocation(String address) async {
    location = await locationFromAddress(address);
    updateMapCamera(location[0].latitude, location[0].longitude);
    addressLoc = LatLng(location[0].latitude, location[0].longitude);
    addressAddress = address;
  }

  void updateMapCamera(double latitude, double longitude) {
    if (_mapController != null) {
      _mapController!
          .animateCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)))
          .then((_) {

        _markers = {
          Marker(
            markerId: const MarkerId('chosenLocation'),
            position: LatLng(latitude, longitude),
          ),
        };
        setState(() {});
      }).catchError((error) {
      });
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 100,
              child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
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
                    decoration: const InputDecoration(
                        hintText: "Search your location",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
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
                icon: const Icon(Icons.house),
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
                    initializeLocation(placePredictions[index].description!);
                    locationController.text =
                        placePredictions[index].description!;
                    locationFocus.unfocus();

                  },
                  location: placePredictions[index].description!,
                ),
              ),
            ),
          ],
        ));
  }
}