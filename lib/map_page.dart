import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_example/cubit/map_cubit.dart';
import 'package:google_maps_example/widgets/chips_section.dart';
import 'package:google_maps_example/widgets/map_bottom_sheet.dart';
import 'package:google_maps_example/widgets/places_search_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<MapCubit, MapCubitState>(
      builder: (context, state) {
        if (state is MapCubitLoaded) {
          final cubit = context.read<MapCubit>();
          return Stack(
            children: [
              GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    cubit.mapController.complete(controller);
                  },
                  initialCameraPosition: CameraPosition(
                    target: state.currentPosition,
                    zoom: 14,
                  ),
                  clusterManagers: {
                    ClusterManager(clusterManagerId: ClusterManagerId('main'))
                  },
                  zoomControlsEnabled: true,
                  padding: EdgeInsets.only(bottom: 300),
                  markers: cubit.convertPointsToMarkers()),
              Column(
                children: [
                  PlacesSearchBar(
                    onSelected: (point) => cubit.cameraToPosition(point, 16),
                  ),
                  ChipsSection(),
                ],
              ),
              MapBottomSheet(
                onTap: (point) => cubit.cameraToPosition(point, 16),
              )
            ],
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    ));
  }
}
