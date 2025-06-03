import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_example/cubit/map_cubit.dart';
import 'package:google_maps_example/model/map_point.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapBottomSheet extends StatefulWidget {
  const MapBottomSheet({required this.onTap, super.key});

  final Function(LatLng) onTap;

  @override
  State<MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends State<MapBottomSheet> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapCubit>();
    final state = context.watch<MapCubit>().state;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.2,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        final allPoints = state is MapCubitLoaded ? state.points : <MapPoint>[];

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Column(
            children: [
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  // Calculate new size based on drag position
                  final newSize = _sheetController.size -
                      (details.primaryDelta! / context.size!.height);
                  _sheetController.jumpTo(newSize.clamp(0.1, 0.5));
                },
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: 24,
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 8),
                  controller: scrollController,
                  itemCount: allPoints.length,
                  itemBuilder: (context, index) {
                    final point = allPoints[index];
                    final iconPath = cubit.getIconByType(point.types);

                    return ListTile(
                      leading: iconPath == null
                          ? Icon(Icons.place, size: 40)
                          : Image.asset(
                              iconPath,
                              width: 40,
                              height: 40,
                            ),
                      title: Text(point.name),
                      subtitle: Text(point.address),
                      onTap: () => widget.onTap(point.coordinates),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
