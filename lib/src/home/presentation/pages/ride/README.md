# Ride Feature – Modules Course en Cours

Cette feature gère le flux complet d'une course : appel du chauffeur, suivi en temps réel, et notation post-course.

## Architecture

```
lib/src/home/
├── domain/models/ride/          # Entités métier
│   ├── ride_model.dart          # Course (statut, positions, infos)
│   ├── rating_model.dart        # Notation (étoiles, tags, commentaire)
│   └── driver_location_model.dart # Position GPS chauffeur
│
├── domain/repositories/
│   └── ride_repository.dart     # Interface API (initiate, track, rate)
│
├── presentation/pages/ride/
│   ├── ongoing_call_page.dart   # Écran appel en cours (m-Call)
│   ├── ride_tracking_page.dart  # Suivi live course (m-followup)
│   └── rating_page.dart         # Notation (m-rate)
│
├── presentation/providers/ride/
│   ├── ride_provider.dart       # État course (positions, statut)
│   └── rating_provider.dart     # État notation (étoiles, tags)
│
└── presentation/widgets/ride/
    ├── call_interface.dart      # UI appel téléphonique
    ├── rating_stars.dart        # Étoiles notation interactives
    └── ride_timeline.dart       # Timeline étapes course
```

## Flux principal

1. **Initiation** → `HomeProvider` appelle `RideProvider.initiateRide()`
2. **Appel** → `OngoingCallPage` affiche infos chauffeur, ETA, bouton appel
3. **Suivi** → `RideTrackingPage` stream GPS via `RideProvider.updateDriverLocation()`
4. **Notation** → `RatingPage` après complétion, appelle `RatingProvider.submitRating()`

## State Management

- `RideProvider` : stocke `Ride? currentRide`, notifie changements positions
- `RatingProvider` : stocke `selectedStars`, `selectedTags`, `comment`

## Routes

```dart
RoutePages.ongoingCall   // '/ongoing-call'
RoutePages.rideTracking  // '/ride-tracking'
RoutePages.rate          // '/rate'
```

## Intégration

Les providers sont injectés au niveau racine dans `AppConfig.createApp()` → MultiProvider.

API calls via `RideRepository` implémentant `ApiClient` (Dio).
