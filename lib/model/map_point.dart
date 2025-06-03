import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;

const desiredTypes = [
  PlaceType.GYM,
  PlaceType.STORE,
];

const icons = {
  PlaceType.GYM: 'assets/gym.png',
  PlaceType.STORE: 'assets/store.png',
};

class MapPoint {
  final String name;
  final String address;
  final List<AddressComponent> addressComponents;
  final google_maps.LatLng coordinates;
  final List<PlaceType> types;

  MapPoint({
    required this.name,
    required this.address,
    required this.addressComponents,
    required this.coordinates,
    required this.types,
  });
}
