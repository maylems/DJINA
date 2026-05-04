// Widget: Timeline des étapes de la course
import 'package:flutter/material.dart';
import 'package:djina_debug/src/home/domain/models/ride/ride_model.dart';

class RideTimeline extends StatelessWidget {
  final RideStatus currentStatus;

  const RideTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData(
        status: RideStatus.searching,
        label: 'Recherche',
        icon: Icons.search,
      ),
      _StepData(
        status: RideStatus.driverFound,
        label: 'Chauffeur trouvé',
        icon: Icons.directions_car,
      ),
      _StepData(
        status: RideStatus.driverArrived,
        label: 'Arrivé',
        icon: Icons.check_circle,
      ),
      _StepData(
        status: RideStatus.started,
        label: 'Course',
        icon: Icons.play_arrow,
      ),
      _StepData(
        status: RideStatus.completed,
        label: 'Terminée',
        icon: Icons.flag,
      ),
    ];

    final currentIndex = steps
        .indexWhere((s) => s.status == currentStatus)
        .clamp(0, steps.length - 1);

    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          _TimelineStep(
            step: steps[i],
            isActive: i <= currentIndex,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _StepData {
  final RideStatus status;
  final String label;
  final IconData icon;

  const _StepData({required this.status, required this.label, required this.icon});
}

class _TimelineStep extends StatelessWidget {
  final _StepData step;
  final bool isActive;
  final bool isLast;

  const _TimelineStep({
    super.key,
    required this.step,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cercle + icône
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(step.icon, color: Colors.white, size: 18),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Label
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              step.label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
