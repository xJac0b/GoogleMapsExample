part of 'map_cubit.dart';

@immutable
sealed class MapCubitState {}

final class MapCubitLoading extends MapCubitState {}

final class MapCubitLoaded extends MapCubitState {
  MapCubitLoaded({
    required this.points,
    required this.currentPosition,
  });

  final LatLng currentPosition;
  final List<MapPoint> points;
}
