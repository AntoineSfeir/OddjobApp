import 'dart:convert';
import 'package:odd_job_app/jobAssets/geolocation/auto_complete_prediction.dart';

class PlaceAutocompleteResponse {
  final String? status;
  final List<AutocompletePreds>? predictions;

  PlaceAutocompleteResponse({this.status, this.predictions});

  factory PlaceAutocompleteResponse.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompleteResponse(
        status: json['status'] as String?,
        predictions: json['predictions'] != null
            ? json['predictions']
                .map<AutocompletePreds>(
                    (json) => AutocompletePreds.fromJson(json))
                .toList()
            : null);
  }

  static PlaceAutocompleteResponse parseAutocompleteResult(
      String responseBody) {
    final parsed = json.decode(responseBody).cast<String, dynamic>();

    return PlaceAutocompleteResponse.fromJson(parsed);
  }
}
