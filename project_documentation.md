# Ethio Explore - Project Documentation

Welcome to the **Ethio Explore** project documentation! This document outlines the architecture, features, services, and overall structure of the application.

## Overview
Ethio Explore is a modern, feature-rich Flutter mobile application designed to be the ultimate digital companion for exploring Ethiopia. It provides offline-first capabilities, intelligent travel planning, real-time navigation, and deep cultural immersion tools for both tourists and locals.

---

## 🏗 Architecture & State Management

The application follows a clean architectural pattern utilizing **Riverpod** for robust, reactive state management. 

### Key Structural Components:
- **`lib/main.dart`**: The entry point of the app, wrapping the entire application in a `ProviderScope` and defining the global `MaterialApp` with the `EthioTheme`.
- **`lib/state/app_state.dart`**: The central repository for user data, including saved trips, favorite destinations, and AI token budgets. It leverages `StateNotifier` to reactively update the UI when data changes.
- **`lib/theme/`**: Contains `ethio_theme.dart` and `ethio_colors.dart`, enforcing a consistent design system (the "Ethiopian Horizon" theme) across all screens using Material 3 principles.
- **`lib/data/sample_data.dart`**: Houses all the statically compiled destination data, cultural insights, and travel directory listings to ensure immediate, offline-ready content without initial database calls.

---

## 🚀 Core Features & Workflows

### 1. Smart Offline Maps & Live Routing (`map_screen.dart`)
A powerful, interactive mapping solution built using `flutter_map` and OpenStreetMap data.
- **Features**: Displays offline-capable map tiles, POIs, and user location.
- **Live Routing**: Integrates with the `RoutingService` to fetch exact street-level paths from the device's location to any destination.
- **Live Tracking**: Utilizes the device's GPS hardware (`geolocator`) to stream position updates, keeping the user's blue dot accurate and optionally locking the camera to follow their movement.
- **Modes**: Supports Walk, Bike, Bus, and Car travel profiles.

### 2. Smart Travel Features (`smart_travel_features_screen.dart`)
A hub for dynamic utilities that assist the traveler on the ground.
- **Bank Locator**: Queries the Overpass API (`BankLocatorService`) to find real, physical bank branches within a configurable radius of the user's live GPS coordinates. It includes the same live routing and tracking engine as the main map to physically guide users to the nearest ATM or branch.
- **Emergency Hotlines**: Quick-access cards to call local police, medical, and tourist assistance.

### 3. AI Trip Planner (`ai_trip_planner_screen.dart`)
A simulated AI engine that generates hyper-personalized itineraries.
- **Features**: The user inputs constraints (e.g., "3 days in Lalibela focusing on history"), and the engine "processes" the request.
- **Parser Optimization**: Generates concise, 12-word actionable bullet points for the itinerary tasks, saving token bandwidth and improving readability.

### 4. Interactive Saved Plans (`saved_plans_screen.dart`)
A sleek, gamified interface for users to manage their active itineraries.
- **Features**: Task checkboxes were replaced with animated, interactive pill cards.
- **Celebration**: As tasks are marked complete, progress bars fill up, culminating in celebratory UI feedback upon finishing a trip.

### 5. Cultural Immersion (`amharic_phrasebook_screen.dart`, `insight_detail_screen.dart`)
- **Phrasebook**: Essential Amharic phrases categorized for easy access, complete with phonetic pronunciations.
- **Insights**: Deep dives into Ethiopian history, food, and culture.

---

## 🔌 Services

The `lib/services/` directory contains standalone modules for handling external APIs and hardware:

1. **`RoutingService`**
   - **Endpoint**: OpenStreetMap Routing Machine (OSRM) `router.project-osrm.org`.
   - **Role**: Takes start/end `LatLng` coordinates and a `TravelMode`, fetches GeoJSON data, and parses it into a list of drawable `LatLng` points and turn-by-turn text instructions.

2. **`BankLocatorService`**
   - **Endpoint**: Overpass API (`overpass-api.de`).
   - **Role**: Executes specialized query language to find nodes tagged as `amenity=bank` within a specified radius of a geographic coordinate. Uses a custom `User-Agent` to prevent rate-limiting.

---

## 🎨 UI/UX Philosophy

The app is built around the **Ethiopian Horizon** design language:
- **Colors**: Deep terracottas, warm golds, and forest greens to reflect the natural landscapes of Ethiopia.
- **Glassmorphism**: Extensive use of blurred backgrounds (`BackdropFilter`) to overlay UI elements onto rich imagery without losing context.
- **Animations**: Soft `AnimatedContainer` and `AnimatedSwitcher` transitions are used globally to make state changes feel fluid and tactile rather than abrupt.
- **Typography**: Emphasizes thick, bold headers paired with highly legible body text.

---

## 🛠 Setup & Installation

To run the application locally:
1. Ensure you have the Flutter SDK installed and configured.
2. Clone the repository and navigate into the root directory.
3. Run `flutter pub get` to fetch all dependencies (`flutter_map`, `latlong2`, `http`, `geolocator`, `flutter_riverpod`).
4. Ensure an emulator is running or a physical device is connected.
5. Execute `flutter run --debug` to compile and launch the application.

> [!NOTE]
> Location permissions are required for the routing and bank locator features to function. Ensure Location Services are enabled on the testing device.
