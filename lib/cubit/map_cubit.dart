import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_example/point_groups.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

part 'map_cubit_state.dart';

class MapCubit extends Cubit<MapCubitState> {
  MapCubit() : super(MapCubitLoading()) {
    _getLocationUpdates();
  }
  final Location locationController = Location();
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  late final StreamSubscription<LocationData>? locationSubscription;

  Set<Marker> _convertPointsToMarkers() {
    return pointGroups.entries.expand((entry) {
      final id = entry.key;
      final points = entry.value;

      return points.map(
        (p) => Marker(
          markerId: MarkerId('${p.latitude},${p.longitude}'),
          position: p,
          infoWindow: InfoWindow(title: 'Point ${p.latitude},${p.longitude}'),
          clusterManagerId: ClusterManagerId(id),
        ),
      );
    }).toSet();
  }

  Set<ClusterManager> _convertPointsToClusterManagers() {
    return pointGroups.entries.map((entry) {
      final id = entry.key;

      return ClusterManager(
        onClusterTap: (cluster) {},
        clusterManagerId: ClusterManagerId(id),
      );
    }).toSet();
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
            markers: _convertPointsToMarkers(),
            clusterManagers: _convertPointsToClusterManagers(),
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

  @override
  Future<void> close() {
    locationSubscription?.cancel();
    return super.close();
  }
}
