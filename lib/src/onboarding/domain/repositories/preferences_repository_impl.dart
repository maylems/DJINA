// data/repositories/preferences_repository_impl.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/preferences_repositories.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  static const String _onboardingKey = 'onboarding_completed';

  @override
  Future<void> saveOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  @override
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }
}