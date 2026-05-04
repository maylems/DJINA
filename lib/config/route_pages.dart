/// Configuration centralisée des routes de l'application
/// Organisé par feature pour une navigation claire
class RoutePages {
  // Routes d'onboarding - Flux d'introduction
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String locationPermission = '/location-permission';

  // Routes d'authentification - Flux de connexion
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otpSignup = '/otp-signup';
  static const String joinLogin = '/join-login';

  // Routes principales - Après connexion
  static const String homepage = '/homepage';
  static const String profile = '/profile';

  // Routes courses - Suivi & notation
  static const String ongoingCall = '/ongoing-call';
  static const String rideTracking = '/ride-tracking';
  static const String rate = '/rate';
}
