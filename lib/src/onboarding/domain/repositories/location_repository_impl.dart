// data/repositories/location_repository_impl.dart

import 'package:permission_handler/permission_handler.dart';
import '../../domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<void> enableLocation() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isDenied || status.isRestricted) {
      await Permission.locationWhenInUse.request();
    } else if (status.isPermanentlyDenied) {
      // L'utilisateur a refusé définitivement → ouvrir les paramètres
      await openAppSettings();
    }
  }

  @override
  Future<bool> hasPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }
}