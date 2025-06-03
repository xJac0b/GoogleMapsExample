import 'package:flutter/material.dart';

class MapChip extends StatelessWidget {
  const MapChip({
    this.text = '',
    this.onTap,
    this.selected = false,
    super.key,
  });

  final String text;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
        onTap: onTap,
        child: Chip(
          backgroundColor:
              selected ? Colors.grey.shade300 : Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          label: Text(text),
        ),
      ),
    );
  }
}
