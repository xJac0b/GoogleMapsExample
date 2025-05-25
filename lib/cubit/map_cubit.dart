import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  Map<String, List<LatLng>> pointGroups = {
    'Osiedle1': [
      LatLng(49.610259850281345, 20.70454385044939),
      LatLng(49.61292938697944, 20.703857205006724),
      LatLng(49.61169717759588, 20.706882736488474),
      LatLng(49.61190747223398, 20.70743795370188),
      LatLng(49.61138607890537, 20.70455457928443),
      LatLng(49.61088901207249, 20.708213112033643),
      LatLng(49.610572694176, 20.70729043222006),
    ],
    'Osiedle2': [
      LatLng(49.62919867961747, 20.75007590636796),
      LatLng(49.62897282335421, 20.75039777141921),
      LatLng(49.63000132955635, 20.748965471941148),
      LatLng(49.62994226053119, 20.75185152856736),
      LatLng(49.62826223797123, 20.75202318996264),
    ],
  };

  Set<Marker> convertPointsToMarkers() {
    if (state is! MapCubitLoaded) {
      return {};
    }
    final currentState = state as MapCubitLoaded;

    return currentState.points.entries.expand((entry) {
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

  Set<ClusterManager> convertPointsToClusterManagers() {
    if (state is! MapCubitLoaded) {
      return {};
    }
    final currentState = state as MapCubitLoaded;

    return currentState.points.entries.map((entry) {
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
            points: pointGroups,
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
