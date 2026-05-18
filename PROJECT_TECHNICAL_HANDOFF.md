# Discover Ethiopia - Technical Project Handoff

## 1. Project Overview
`Discover Ethiopia` is an offline-first Flutter mobile app for travel discovery and trip planning focused on Ethiopian destinations, culture, and local services.

Primary goals:
- Help users explore destinations without always relying on internet access.
- Provide practical trip planning (itinerary, budget, schedule, saved plans).
- Offer local context (culture, phrasebook, safety, banking, nearby services).
- Blend static offline data with optional AI-assisted planning.

Tech stack:
- Flutter (Material 3)
- Local persistence: `shared_preferences`
- Maps: `flutter_map` + `latlong2`
- Device location: `geolocator`
- External API calls: `http`
- Optional external navigation links: `url_launcher` (dependency present)

---

## 2. Problem This App Solves
Travel apps are often internet-dependent, generic, and weak on local context. This app addresses:
- Offline exploration and planning for users with limited/expensive connectivity.
- Ethiopia-specific travel content (destinations, festivals, culture, services).
- Trip organization in one place: stops, day plans, budgets, checklists, saved AI plans.
- Practical local needs: banks/ATMs, phrasebook, safety notes, quick guidance.

---

## 3. High-Level Architecture
Entry/bootstrap flow:
1. `lib/main.dart`
- Initializes Flutter binding.
- Loads persisted app state via `loadAppState()`.
- Starts app with hydrated state.

2. `lib/app.dart`
- Root widget: `EthioExploreApp`.
- Wires `AppStateScope` (global state scope).
- Configures theme/light-dark mode, splash screen, shell routes.
- Main shell (`EthioExploreShell`) hosts tabbed navigation.

State management pattern:
- `ChangeNotifier` + `InheritedNotifier` (custom lightweight state container).
- No external state management package (Provider/Bloc/Riverpod not used).

Data model pattern:
- Strongly-typed model classes in `lib/models/*`.
- Serialization/deserialization for persisted trip plans and saved AI plans.

---

## 4. Core Code Locations (Most Important Files)

### App bootstrap and shell
- `lib/main.dart`: app start and state hydration.
- `lib/app.dart`: root app, themes, tab shell, global navigation helpers.

### Global state and persistence
- `lib/state/app_state.dart`
- `lib/state/app_scope.dart`
- `lib/data/local_store.dart`

Responsibilities in `app_state.dart`:
- Search/filter state
- Favorites
- Trip plan (days, stops, notes, times, budget)
- Language and theme mode
- Saved AI trip plans and checklist tasks
- Load/reset/persist routines

### Data and domain models
- `lib/models/app_models.dart`: destination, directory services, trip plan, AI plan models.
- `lib/models/travel_features_models.dart`: banking, phrasebook, packing, comparison models.
- `lib/data/sample_data.dart`: primary destination/culture/directory seed data.
- `lib/data/travel_features_data.dart`: smart features data (banks/packing/comparison/etc.).

### Major feature screens
- `lib/screens/home_screen.dart`: search, categories, featured destinations, insights entry points.
- `lib/screens/destination_details_screen.dart`: destination deep-dive UI + map section.
- `lib/screens/map_screen.dart`: interactive smart map, filters, local POIs, offline-style routing simulation.
- `lib/screens/trip_planner_screen.dart`: full day-by-day planner UI and trip editing.
- `lib/screens/ai_trip_planner_screen.dart`: AI itinerary request UX + save plan.
- `lib/screens/saved_plans_screen.dart`: persisted AI plans and task completion.
- `lib/screens/directory_screen.dart`: hotels/car rentals/tour agencies.
- `lib/screens/service_detail_screen.dart`: detail view for a selected service.
- `lib/screens/travel_toolkit_screen.dart`: offline helper toolkit modules.
- `lib/screens/smart_travel_features_screen.dart`: banks + location, packing generator, destination comparison.
- `lib/screens/amharic_phrasebook_screen.dart`: phrasebook interactions.
- `lib/screens/insight_detail_screen.dart`: cultural insight detail experience.
- `lib/screens/favorites_screen.dart`: saved destinations.
- `lib/screens/splash_screen.dart`: animated launch transition.

### Theming/UI primitives
- `lib/theme/app_theme.dart`: theme tokens and theme setup.
- `lib/widgets/ui_components.dart`: shared design components/colors/spacing/cards/chips.

### External integration (AI)
- `lib/services/gemini_trip_planner_service.dart`
- Calls Google Generative Language API (`generateContent`) using API key from:
  - `--dart-define=GEMINI_API_KEY=YOUR_KEY`

---

## 5. Feature-by-Feature Implementation Map

1. Destination discovery
- Data source: `sampleDestinations` in `lib/data/sample_data.dart`
- Search/filter logic: `AppState.filteredDestinations`
- UI: `HomeScreen` + `DestinationCard` components

2. Favorites
- Toggle/check: `AppState.toggleFavorite`, `AppState.isFavorite`
- Persistence key: `_favoritesKey`
- UI: `favorites_screen.dart`, cards in home/map/details

3. Offline map + local POI exploration
- Screen: `lib/screens/map_screen.dart`
- Maps engine: `flutter_map`
- Tile providers: OSM + ArcGIS world imagery (toggle)
- Local POI dataset: `_offlinePois` inside `MapScreen`
- Simulated route building + turn-by-turn text generated locally

4. Trip planner (manual)
- Trip model: `TripPlan`, `TripDayPlan`, `TripStop`
- State operations: create, add/remove stop, reorder, set times, notes, budget
- Persistence key: `_tripPlanKey`
- Screen: `trip_planner_screen.dart`

5. AI trip planner
- UI flow: `ai_trip_planner_screen.dart`
- Service: `gemini_trip_planner_service.dart`
- Output parsing into sections: `_parseSections(...)`
- Save output: `AppState.saveAiTripPlan(...)`
- Persistence key: `_savedAiPlansKey`

6. Directory/services module
- Data sets: `sampleHotels`, `sampleCarRentals`, `sampleTourAgencies`
- Models: `Hotel`, `CarRental`, `TourAgency` implementing `DirectoryService`
- UI: `directory_screen.dart` and `service_detail_screen.dart`

7. Toolkit and smart features
- `travel_toolkit_screen.dart`: currency converter (static rates), expense tracker, offline assistant patterns, culture notes
- `smart_travel_features_screen.dart`: geolocator-based branch sorting, packing checklist generator, destination comparison + quiz

8. Localization and theme
- Localization map: `lib/state/app_localization.dart` (English/Amharic dictionary-based)
- Theme mode in app state (`ThemeMode.light`/`dark`) with persistence

---

## 6. Libraries and Why They Are Used
- `shared_preferences`: persist favorites/trip plans/query/settings/saved plans.
- `flutter_map`: render map canvas without Google Maps SDK dependency.
- `latlong2`: coordinate and distance helpers for map logic.
- `geolocator`: location permission flow and current position retrieval.
- `http`: AI API requests and model resolution calls.
- `url_launcher`: available for deep links/external navigation actions.
- `cupertino_icons`: icon support.

Dev libraries:
- `flutter_lints`: lint baseline.
- `flutter_launcher_icons`: app icon generation from `Logo.png`.

---

## 7. Persistent Storage Keys (Important for Migration/Debugging)
Defined in `AppState`:
- `favorites`
- `trip_plan_v2`
- `language`
- `theme_mode`
- `category`
- `query`
- `saved_ai_plans_v1`

If key names change, existing user local data may be lost unless migration is added.

---

## 8. Build/Run Notes
Commands:
- `flutter pub get`
- `flutter run`
- `flutter analyze`

AI feature setup:
- Run with `--dart-define=GEMINI_API_KEY=YOUR_KEY`
- Without key, AI planner UI still renders but generation is blocked by guard checks.

---

## 9. Known Engineering Observations
- The app is strongly data-driven through local sample data files; adding destinations/services usually means editing seed lists.
- Some text encoding artifacts are visible in source content/comments (likely copy/paste encoding issues) but do not block architecture.
- Map routing is local/simulated (not a real routing engine). If turn-by-turn production-grade routing is required, integrate a routing backend/offline routing package.
- Automated tests are minimal (`test/widget_test.dart` scaffold); core business flows are currently mostly untested.

---

## 10. Suggested Onboarding Path for a New Developer
1. Read `lib/app.dart` and `lib/state/app_state.dart` first.
2. Trace navigation from shell tabs into each screen.
3. Review `lib/models/app_models.dart` and `lib/data/sample_data.dart` to understand domain shape.
4. Run app and validate core flows: search, favorites, trip planner, map, directory, AI planner.
5. Inspect persistence changes by toggling data and restarting app.

---

## 11. Quick Change Guide
- Add a destination: edit `sampleDestinations` in `lib/data/sample_data.dart`.
- Add a service listing: edit corresponding sample list in `sample_data.dart`.
- Change trip logic: `lib/state/app_state.dart` + `lib/screens/trip_planner_screen.dart`.
- Change AI prompt behavior: `lib/services/gemini_trip_planner_service.dart`.
- Change global look-and-feel: `lib/theme/app_theme.dart` and `lib/widgets/ui_components.dart`.

---

## 12. Repository Structure Snapshot
- `lib/`: all app code
- `assets/images/`: static local media used by destinations/services/insights
- `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`: platform runners
- `pubspec.yaml`: dependencies, assets, launcher icon config

This document is intended to be a single-file technical handoff for incoming developers.
