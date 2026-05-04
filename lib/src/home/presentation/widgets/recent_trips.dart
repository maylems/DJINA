// src/home/presentation/widgets/recent_trips.dart
//
// S'abonne à HomeProvider.tripsRefreshKey — se recharge automatiquement
// quand refreshRecentTrips() est appelé (après annulation ou confirmation).

import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:djina_debug/src/home/domain/repositories/course_repository.dart';
import 'package:djina_debug/src/home/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RecentTrips extends StatefulWidget {
  const RecentTrips({super.key});

  @override
  State<RecentTrips> createState() => _RecentTripsState();
}

class _RecentTripsState extends State<RecentTrips> {
  final CourseRepository _repo = CourseRepository();

  List<Map<String, dynamic>> _courses   = [];
  bool _isLoading  = true;
  int  _lastKey    = -1; // dernière clé chargée

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Se déclenche à chaque fois que tripsRefreshKey change
    final key = context.watch<HomeProvider>().tripsRefreshKey;
    if (key != _lastKey) {
      _lastKey = key;
      _loadCourses();
    }
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    final courses = await _repo.getCompletedCourses();
    if (!mounted) return;
    setState(() {
      _courses   = courses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Mes Trajets',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 10),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_courses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Aucun trajet terminé pour le moment',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _courses.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (_, i) => _TripItem(course: _courses[i]),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TripItem extends StatelessWidget {
  final Map<String, dynamic> course;
  const _TripItem({required this.course});

  String get _departure    => course['starting_landmark'] as String? ?? 'Départ';
  String get _destination  => course['arrival_landmark']  as String? ?? 'Destination';

  String get _price {
    final p = course['final_price'] ?? course['initial_price'];
    if (p == null) return '';
    return 'F $p';
  }

  String get _date {
    final raw = course['completed_at'] as String?;
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_car,
                size: 20, color: Colors.grey),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _departure,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.arrow_forward,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _destination,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_price.isNotEmpty)
                Text(_price,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor)),
              if (_date.isNotEmpty)
                Text(_date,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }
}