import 'package:flutter/material.dart';

class MapChip extends StatelessWidget {
  const MapChip({
    this.text = '',
    this.onTap,
    super.key,
  });

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
        onTap: onTap,
        child: Chip(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          label: Text(text),
        ),
      ),
    );
  }
}
