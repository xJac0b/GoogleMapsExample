import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places;
import 'package:google_maps_example/infrastructure/place_service.dart';
import 'package:google_maps_example/model/map_point.dart';
import 'package:google_maps_example/model/place_input.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

part 'map_cubit_state.dart';

class MapCubit extends Cubit<MapCubitState> {
  MapCubit() : super(MapCubitLoading()) {
    initPoints();
  }
  final Location locationController = Location();
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  late final StreamSubscription<LocationData>? locationSubscription;

  Future<void> initPoints() async {
    final placeService =
        PlaceService.getInstance('AIzaSyCyLTsx-sSU52B9slUL5Eg9pV_wEYzaWfs');

    for (var place in inputPlaces) {
      final point = await placeService.fetchPoint(place);
      if (point != null) {
        mapPoints.add(point);
      }
    }
    _getLocationUpdates();
  }

  List<MapPoint> mapPoints = [];
  List<PlaceInput> inputPlaces = [
    PlaceInput(
        name: 'Fitness Trzy Korony', address: 'Lwowska 80, 33-300 Nowy Sącz'),
    PlaceInput(
        name: 'Żabka | Prosto z pieca',
        address: 'Lwowska 63, 33-300 Nowy Sącz'),
    PlaceInput(
        name: 'Żabka',
        address: 'Generała Władysława Sikorskiego 33, 33-300 Nowy Sącz'),
    PlaceInput(
        name: 'Oxy Gym | Siłownia, fitness, trening EMS',
        address: 'Kochanowskiego 20, 33-300 Nowy Sącz'),
  ];

  Set<Marker> convertPointsToMarkers() {
    if (state is! MapCubitLoaded) {
      return {};
    }
    final currentState = state as MapCubitLoaded;

    return currentState.points.map((mapPoint) {
      final iconPath = getIconByType(mapPoint.types);
      return Marker(
        markerId: MarkerId('${mapPoint.coordinates}'),
        position: mapPoint.coordinates,
        infoWindow: InfoWindow(title: mapPoint.name, snippet: mapPoint.address),
        onTap: () {
          cameraToPosition(
            mapPoint.coordinates,
            16,
          );
        },
        icon: iconPath != null
            ? AssetMapBitmap(iconPath, width: 32, height: 32)
            : BitmapDescriptor.defaultMarker,
        clusterManagerId: ClusterManagerId('main'),
      );
    }).toSet();
  }

  Future<void> clearFilteredPoints() async {
    if (state is! MapCubitLoaded) {
      return;
    }
    final currentState = state as MapCubitLoaded;

    emit(MapCubitLoaded(
      points: mapPoints,
      currentPosition: currentState.currentPosition,
    ));

    final matchingLatLngs =
        mapPoints.map((point) => point.coordinates).toList();
    await cameraToBounds(boundsFromLatLngList(matchingLatLngs));
  }

  Future<void> filterPointsByType(places.PlaceType type) async {
    if (state is! MapCubitLoaded) {
      return;
    }
    final currentState = state as MapCubitLoaded;

    final filteredPoints =
        mapPoints.where((point) => point.types.contains(type)).toList();

    emit(MapCubitLoaded(
      points: filteredPoints,
      currentPosition: currentState.currentPosition,
    ));

    final matchingLatLngs =
        filteredPoints.map((point) => point.coordinates).toList();

    await cameraToBounds(boundsFromLatLngList(matchingLatLngs));
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> points) {
    final southwestLat =
        points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final southwestLng =
        points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    final northeastLat =
        points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final northeastLng =
        points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );
  }

  Future<void> _getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();

    if (serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    } else {
      return;
    }
    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    locationSubscription = locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        emit(
          MapCubitLoaded(
            points: (state is MapCubitLoaded)
                ? (state as MapCubitLoaded).points
                : mapPoints,
            currentPosition: LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            ),
          ),
        );
      }
    });
  }

  Future<void> cameraToPosition(LatLng pos, [double zoom = 13]) async {
    final GoogleMapController controller = await mapController.future;

    final CameraPosition newCameraPosition = CameraPosition(
      target: pos,
      zoom: zoom,
    );

    controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  Future<void> cameraToBounds(LatLngBounds bounds) async {
    final GoogleMapController controller = await mapController.future;

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  @override
  Future<void> close() {
    locationSubscription?.cancel();
    return super.close();
  }

  String? getIconByType(List<places.PlaceType> types) {
    for (var type in types) {
      if (icons.containsKey(type)) {
        return icons[type];
      }
    }
    return null;
  }
}
