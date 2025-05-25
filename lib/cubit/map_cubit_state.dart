part of 'map_cubit.dart';

@immutable
sealed class MapCubitState {}

final class MapCubitLoading extends MapCubitState {}

final class MapCubitLoaded extends MapCubitState {
  MapCubitLoaded({
    required this.markers,
    required this.clusterManagers,
    required this.currentPosition,
  });

  final LatLng currentPosition;
  final Set<Marker> markers;
  final Set<ClusterManager> clusterManagers;
}
