// Widget: Étoiles interactives pour notation
import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final int selectedStars;
  final int maxStars;
  final double size;
  final ValueChanged<int>? onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const RatingStars({
    super.key,
    required this.selectedStars,
    this.maxStars = 5,
    this.size = 40,
    this.onChanged,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxStars, (index) {
        final value = index + 1;
        final isSelected = selectedStars >= value;
        final icon = isSelected ? Icons.star : Icons.star_border;

        return GestureDetector(
          onTap: onChanged != null ? () => onChanged!(value) : null,
          child: Icon(
            icon,
            color: isSelected ? activeColor : inactiveColor,
            size: size,
          ),
        );
      }),
    );
  }
}
