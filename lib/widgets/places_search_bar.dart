import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_example/cubit/map_cubit.dart';
import 'package:google_maps_example/model/map_point.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacesSearchBar extends StatefulWidget {
  const PlacesSearchBar({
    required this.onSelected,
    super.key,
  });
  final Function(LatLng) onSelected;

  @override
  State<PlacesSearchBar> createState() => _PlacesSearchBarState();
}

class _PlacesSearchBarState extends State<PlacesSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: BlocListener<MapCubit, MapCubitState>(
          listenWhen: (prev, curr) {
            return prev is MapCubitLoaded &&
                curr is MapCubitLoaded &&
                prev.points != curr.points;
          },
          listener: (context, state) {
            // Odśwież podpowiedzi, bez zmiany treści
            _controller.text = _controller.text;
          },
          child: TypeAheadField<MapPoint>(
            controller: _controller,
            builder: (context, controller, focusNode) {
              var outlineInputBorder = OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey),
              );
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      hintText: 'Search places',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: value.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                controller.clear();
                                controller.text = '';
                              },
                            )
                          : null,
                      enabledBorder: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      errorBorder: outlineInputBorder,
                      border: outlineInputBorder,
                      disabledBorder: outlineInputBorder,
                      focusedErrorBorder: outlineInputBorder,
                    ),
                  );
                },
              );
            },
            itemBuilder: (BuildContext context, MapPoint value) => ListTile(
              title: Text(value.name),
              subtitle: Text(value.address),
            ),
            suggestionsCallback: (String pattern) async {
              final state = context.read<MapCubit>().state;

              if (state is! MapCubitLoaded) return [];

              final lowerPattern = pattern.toLowerCase();
              return state.points.where((point) {
                return point.name.toLowerCase().contains(lowerPattern) ||
                    point.address.toLowerCase().contains(lowerPattern) ||
                    point.addressComponents.any((component) =>
                        component.name.toLowerCase().contains(lowerPattern) ||
                        component.shortName
                            .toLowerCase()
                            .contains(lowerPattern));
              }).toList();
            },
            emptyBuilder: (context) => ListTile(
              title: Text('No results found'),
            ),
            onSelected: (point) {
              _controller.text = point.name;
              widget.onSelected(point.coordinates);
            },
          ),
        ),
      ),
    );
  }
}
