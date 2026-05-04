// src/home/presentation/pages/home_page.dart

import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:djina_debug/src/home/presentation/providers/home_provider.dart';
import 'package:djina_debug/src/home/presentation/providers/ride/ride_provider.dart';
import 'package:djina_debug/src/home/presentation/providers/ride/rating_provider.dart';
import 'package:djina_debug/src/home/domain/models/ride/driver_location_model.dart';
import 'package:djina_debug/src/home/presentation/widgets/home_header.dart';
import 'package:djina_debug/src/home/presentation/widgets/search_section.dart';
import 'package:djina_debug/src/home/presentation/widgets/services_grid.dart';
import 'package:djina_debug/src/home/presentation/widgets/recent_trips.dart';
import 'package:djina_debug/src/drawer/presentation/pages/profile_page.dart';
import 'package:djina_debug/src/drawer/presentation/pages/security_page.dart';
import 'package:djina_debug/src/drawer/presentation/pages/history_page.dart';
import 'package:djina_debug/src/drawer/presentation/pages/referral_page.dart';
import 'package:djina_debug/src/drawer/presentation/pages/notifications_page.dart';
import 'package:djina_debug/src/drawer/presentation/pages/language_page.dart';
import 'package:djina_debug/src/drawer/presentation/pages/about_page.dart';
import 'package:djina_debug/src/drawer/presentation/pages/support_page.dart';
import 'package:djina_debug/src/drawer/presentation/pages/systems_page.dart';
import 'package:djina_debug/src/auth/presentation/providers/auth_provider.dart';
import 'package:djina_debug/config/route_pages.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthentication();
    });
  }

  Widget _buildDrawer(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user         = authProvider.currentUser;
        final displayName  = user?.fullName ?? 'Utilisateur';
        final phone        = user?.phone ?? '';
        final email        = user?.email ?? '';
        final profileImage = user?.profileImage;

        return Drawer(
          child: Column(
            children: [
              Container(
                height: 100,
                color: AppTheme.primaryColor,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios,
                            color: AppTheme.secondaryColor, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: AppTheme.primaryColor,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('PARAMETRE',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryColor,
                                  letterSpacing: 1)),
                        ),
                         const SizedBox(height: 12),
                         _buildDrawerItem(context, Icons.person_outline, 'Profil'),
                         _buildDrawerItem(context, Icons.security, 'Sécurité'),
                         _buildDrawerItem(context, Icons.history, 'Historique'),
                         _buildDrawerItem(context, Icons.card_giftcard, 'Parainage'),
                         _buildDrawerItem(context, Icons.notifications_outlined, 'Notifications'),
                         _buildDrawerItem(context, Icons.language, 'Langue'),
                         _buildDrawerItem(context, Icons.info_outline, 'A propos'),
                         _buildDrawerItem(context, Icons.help_outline, 'Support'),
                         _buildDrawerItem(context, Icons.flag_outlined, 'Systems'),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 45,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Parainage',
                                      style: TextStyle(
                                          color: AppTheme.secondaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: TextButton(
                                  onPressed: () =>
                                      _handleLogout(context, authProvider),
                                  child: const Text('Se Déconnecter',
                                      style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                          image: profileImage != null
                              ? DecorationImage(
                                  image: NetworkImage(profileImage),
                                  fit: BoxFit.cover)
                              : null,
                        ),
                        child: profileImage == null
                            ? Center(
                                child: Text(_initials(displayName),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)))
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.secondaryColor),
                                overflow: TextOverflow.ellipsis),
                            if (phone.isNotEmpty)
                              Text(phone,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis),
                            if (email.isNotEmpty)
                              Text(email,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    Navigator.of(context).pop();
    authProvider.logoutWithNavigator(rootNavigator);
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // 🧪 Afficher le menu de test
  void _showTestMenu(BuildContext context) {
    final pageContext = context; // Sauvegarder le contexte de la page
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Test des pages Ride',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Ongoing Call Page'),
                subtitle: const Text('Écran "Chauffeur en route"'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _testOngoingCallPage(pageContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.blue),
                title: const Text('Ride Tracking Page'),
                subtitle: const Text('Suivi de course en direct'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _testRideTrackingPage(pageContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text('Rating Page'),
                subtitle: const Text('Notation après course'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _testRatingPage(pageContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.purple),
                title: const Text('Flux complet'),
                subtitle: const Text('Call → Tracking → Rating'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _testFullFlow(pageContext);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 🧪 Test: OngoingCallPage (avec fake ride)
  Future<void> _testOngoingCallPage(BuildContext context) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    rideProvider.reset();

    if (kDebugMode) {
      print('🧪 Test: Initialisation fake ride pour OngoingCallPage...');
    }

    await rideProvider.initiateRide(
      driverId: 'test_driver_001',
      driverName: 'Jean Test',
      driverPhoto: '',
      vehicleModel: 'Toyota Camry',
      vehiclePlate: 'TEST-123',
      vehicleColor: 'Blanc',
      pickupLat: 48.8566,
      pickupLng: 2.3522,
      pickupAddress: '123 Rue de Test, Paris',
      destinationLat: 48.8584,
      destinationAddress: 'Tour Eiffel, Paris',
    );

    // Attendre que le chauffeur soit trouvé (3s dans provider)
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;
    Navigator.pushNamed(context, RoutePages.ongoingCall);
  }

  // 🧪 Test: RideTrackingPage (avec ride en cours)
  Future<void> _testRideTrackingPage(BuildContext context) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    rideProvider.reset();

    await rideProvider.initiateRide(
      driverId: 'test_driver_001',
      driverName: 'Jean Test',
      driverPhoto: '',
      vehicleModel: 'Toyota Camry',
      vehiclePlate: 'TEST-123',
      vehicleColor: 'Blanc',
      pickupLat: 48.8566,
      pickupLng: 2.3522,
      pickupAddress: '123 Rue de Test, Paris',
      destinationLat: 48.8584,
      destinationAddress: 'Tour Eiffel, Paris',
    );
    await Future.delayed(const Duration(seconds: 4));

    // Simule que le chauffeur est arrivé (distance < 50m)
    rideProvider.updateDriverLocation(
      DriverLocation(
        driverId: 'test_driver_001',
        latitude: 48.8566,
        longitude: 2.3522,
        bearing: 0,
        speed: 0,
        timestamp: DateTime.now(),
      ),
    );

    if (!mounted) return;
    Navigator.pushNamed(context, RoutePages.rideTracking);
  }

  // 🧪 Test: RatingPage (directement)
  Future<void> _testRatingPage(BuildContext context) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    rideProvider.reset();
    ratingProvider.reset();

    // Créer une ride et la compléter
    await rideProvider.initiateRide(
      driverId: 'test_driver_001',
      driverName: 'Jean Test',
      driverPhoto: '',
      vehicleModel: 'Toyota Camry',
      vehiclePlate: 'TEST-123',
      vehicleColor: 'Blanc',
      pickupLat: 48.8566,
      pickupLng: 2.3522,
      pickupAddress: '123 Rue de Test, Paris',
      destinationLat: 48.8584,
      destinationAddress: 'Tour Eiffel, Paris',
    );
    await Future.delayed(const Duration(seconds: 4));
    rideProvider.completeRide(finalFare: 25.50);

    if (!mounted) return;
    Navigator.pushNamed(context, RoutePages.rate);
  }

  // 🧪 Test: Flux complet (Call → Tracking → Rating)
  Future<void> _testFullFlow(BuildContext context) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    rideProvider.reset();
    ratingProvider.reset();

    // Étape 1: Initiate ride
    await rideProvider.initiateRide(
      driverId: 'test_driver_001',
      driverName: 'Jean Test',
      driverPhoto: '',
      vehicleModel: 'Toyota Camry',
      vehiclePlate: 'TEST-123',
      vehicleColor: 'Blanc',
      pickupLat: 48.8566,
      pickupLng: 2.3522,
      pickupAddress: '123 Rue de Test, Paris',
      destinationLat: 48.8584,
      destinationAddress: 'Tour Eiffel, Paris',
    );
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    // Étape 2: Ongoing Call Page
    Navigator.pushNamed(context, RoutePages.ongoingCall);

    // Étape 3: Après 3s, simulate driver arrived → go to Tracking
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      rideProvider.updateDriverLocation(
        DriverLocation(
          driverId: 'test_driver_001',
          latitude: 48.8566,
          longitude: 2.3522,
          bearing: 0,
          speed: 0,
          timestamp: DateTime.now(),
        ),
      );
      Navigator.pushNamed(context, RoutePages.rideTracking);
    });

    // Étape 4: Après 2s de tracking, simulate ride start (passager monte)
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted && rideProvider.currentRide != null) {
        rideProvider.startRide();
      }
    });

    // Étape 5: Après 3s de course, complete → RatingPage
    Future.delayed(const Duration(seconds: 9), () {
      if (mounted && rideProvider.currentRide != null) {
        rideProvider.completeRide(finalFare: 25.50);
        Navigator.pushNamed(context, RoutePages.rate);
      }
    });
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppTheme.secondaryColor, size: 22),
        title: Text(title,
            style: const TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.w400)),
        onTap: () {
          Navigator.pop(context);
          if (title == 'Profil') {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfilePage()));
          } else if (title == 'Sécurité') {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SecurityPage()));
          } else if (title == 'Historique') {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HistoryPage()));
          } else if (title == 'Parainage') {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReferralPage()));
          } else if (title == 'Notifications') {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()));
           } else if (title == 'Langue') {
             Navigator.push(context,
                 MaterialPageRoute(builder: (_) => const LanguagePage()));
           } else if (title == 'A propos') {
             Navigator.push(context,
                 MaterialPageRoute(builder: (_) => const AboutPage()));
           } else if (title == 'Support') {
             Navigator.push(context,
                 MaterialPageRoute(builder: (_) => const SupportPage()));
           } else if (title == 'Systems') {
             Navigator.push(context,
                 MaterialPageRoute(builder: (_) => const SystemsPage()));
           }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          drawer: _buildDrawer(context),
          body: Column(
            children: [
              const HomeHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SearchSection(),
                      ServicesGrid(
                        selectedService: homeProvider.selectedService,
                        onServiceSelected: homeProvider.selectService,
                      ),
                      // ✅ Se recharge automatiquement via tripsRefreshKey
                      const RecentTrips(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 🧪 Bouton de test pour les nouvelles pages Ride
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showTestMenu(context),
            child: const Icon(Icons.taxi_alert),
            backgroundColor: Colors.green,
            tooltip: 'Test Ride Pages',
          ),
        );
      },
    );
  }
}