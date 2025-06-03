import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:google_maps_example/cubit/map_cubit.dart';
import 'package:google_maps_example/widgets/map_chip.dart';

class ChipsSection extends StatefulWidget {
  const ChipsSection({super.key});

  @override
  State<ChipsSection> createState() => _ChipsSectionState();
}

class _ChipsSectionState extends State<ChipsSection> {
  PlaceType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapCubit>();
    final state = context.watch<MapCubit>().state;

    if (state is MapCubitLoaded) {
      final Set<PlaceType> types = {};

      for (var point in cubit.mapPoints) {
        for (var type in point.types) {
          types.add(type);
        }
      }

      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 60,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            MapChip(
                text: 'My location',
                onTap: () => cubit.cameraToPosition(state.currentPosition, 16)),
            if (_selectedType != null)
              MapChip(
                  text: 'Show all',
                  onTap: () {
                    cubit.clearFilteredPoints();
                    setState(() => _selectedType = null);
                  }),
            ...types.map(
              (type) => MapChip(
                text: type.name[0] +
                    type.name.substring(1).toLowerCase().replaceAll('_', ' '),
                onTap: () async {
                  await cubit.filterPointsByType(type);
                  setState(() => _selectedType = type);
                },
                selected: _selectedType == type,
              ),
            )
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
