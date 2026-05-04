import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:djina_debug/config/app_navigation.dart';
import 'package:djina_debug/config/route_pages.dart';
import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:djina_debug/src/auth/presentation/providers/auth_provider.dart';
import 'package:djina_debug/src/home/presentation/providers/ride/providers.dart';

/// Configuration principale de l'application
class AppConfig {

  /// Route initiale de l'application
  static const String initialRoute = RoutePages.splash;

  /// Configuration des routes pour MaterialApp
  static Map<String, WidgetBuilder> get routes => AppNavigation.routes;

  /// Titre de l'application
  static const String appTitle = 'DJINA';

  /// Configuration du thème
  static ThemeData get theme => AppTheme.theme();

  /// Configuration pour MaterialApp avec providers globaux
  static Widget createApp() {
    return MultiProvider(
      providers: [
        // AuthProvider au niveau racine → accessible depuis toutes les pages
        // (LoginPage, SignupPage, OtpSignupPage, HomePage/drawer, logout)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // RideProvider → gestion course en cours (appel, suivi)
        ChangeNotifierProvider(create: (_) => RideProvider()),

        // RatingProvider → notation post-course
        ChangeNotifierProvider(create: (_) => RatingProvider()),
      ],
      child: MaterialApp(
        title: appTitle,
        theme: theme,
        initialRoute: initialRoute,
        routes: routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}