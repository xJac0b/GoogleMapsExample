import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:google_maps_example/model/map_point.dart';
import 'package:google_maps_example/model/place_input.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;

class PlaceService {
  static PlaceService? _instance;
  final FlutterGooglePlacesSdk _googlePlaces;

  PlaceService._internal(String apiKey)
      : _googlePlaces = FlutterGooglePlacesSdk(apiKey);

  static PlaceService getInstance(String apiKey) {
    _instance ??= PlaceService._internal(apiKey);
    return _instance!;
  }

  Future<MapPoint?> fetchPoint(PlaceInput input) async {
    final query = '${input.name}, ${input.address}';

    final searchResponse =
        await _googlePlaces.findAutocompletePredictions(query);
    if (searchResponse.predictions.isEmpty) return null;

    final prediction = searchResponse.predictions.first;
    final placeId = prediction.placeId;

    final detailsResponse = await _googlePlaces.fetchPlace(
      placeId,
      fields: [
        PlaceField.Location,
        PlaceField.Types,
        PlaceField.Name,
        PlaceField.Address,
        PlaceField.AddressComponents
      ],
    );

    final place = detailsResponse.place;

    if (place == null ||
        place.latLng == null ||
        place.name == null ||
        place.address == null) {
      return null;
    }

    return MapPoint(
      name: place.name!,
      address: place.address!,
      coordinates: google_maps.LatLng(
        place.latLng!.lat,
        place.latLng!.lng,
      ),
      addressComponents: place.addressComponents ?? [],
      types:
          place.types?.where((type) => desiredTypes.contains(type)).toList() ??
              [],
    );
  }
}
