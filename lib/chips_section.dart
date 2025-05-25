import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_example/cubit/map_cubit.dart';
import 'package:google_maps_example/map_chip.dart';
import 'package:google_maps_example/point_groups.dart';

class ChipsSection extends StatefulWidget {
  const ChipsSection({super.key});

  @override
  State<ChipsSection> createState() => _ChipsSectionState();
}

class _ChipsSectionState extends State<ChipsSection> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapCubit>();
    final state = context.watch<MapCubit>().state;

    return state is MapCubitLoaded
        ? Positioned(
            top: 0,
            child: SafeArea(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    MapChip(
                        text: 'Current location',
                        onTap: () =>
                            cubit.cameraToPosition(state.currentPosition, 16)),
                    MapChip(
                        text: 'Osiedle1',
                        onTap: () {
                          final points = pointGroups['Osiedle1']!;
                          if (points.isNotEmpty) {
                            cubit.cameraToPosition(points.first);
                          }
                        }),
                    MapChip(
                        text: 'Osiedle2',
                        onTap: () {
                          final points = pointGroups['Osiedle2']!;
                          if (points.isNotEmpty) {
                            cubit.cameraToPosition(points.first);
                          }
                        }),
                    MapChip(text: 'Gyms'),
                    MapChip(text: 'Pubs'),
                    MapChip(text: 'Restaurants'),
                    MapChip(text: 'Cafes'),
                    MapChip(text: '...'),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
