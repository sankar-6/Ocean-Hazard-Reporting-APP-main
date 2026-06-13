# Ocean Hazard Reporter – Project Documentation

## 1. Overview
Ocean Hazard Reporter is a cross-platform Flutter app to report, visualize, and analyze ocean/coastal hazards. It integrates Firebase for authentication and device services for location, notifications, offline storage, and interacts with a REST backend for reports, analytics, and media uploads.

## 2. Tech Stack
- Flutter 3 / Dart 3
- State: `flutter_riverpod`
- Navigation: `go_router`
- Backend HTTP: `dio`
- Auth: `firebase_core`, `firebase_auth` (Google provider)
- Local storage: `hive`, `shared_preferences`
- Device: `geolocator`, `location`, `camera`, `image_picker`, `permission_handler`, `flutter_local_notifications`
- Maps/UI: `google_maps_flutter`, `fl_chart`, `syncfusion_flutter_charts`

## 3. Project Structure
```
lib/
  core/
    providers/            # Riverpod providers (auth, token sync)
    routing/              # GoRouter and auth gating
    services/             # Cross-cutting services (auth, api, location, notifications, offline)
    theme/                # App themes
  features/
    auth/                 # Auth screens and widgets
    dashboard/            # Main dashboard
    map/                  # Map and hotspot visualizations
    profile/              # User profile
    reporting/            # Create, list, verify reports
    settings/             # App settings
    social_media/         # Social stream and filters
    splash/               # Splash screen
  models/                 # App models (user, report, social post)
  main.dart               # App bootstrap
```

## 4. Environments and Bootstrap
- `main.dart` initializes:
  - Firebase (`Firebase.initializeApp` with `FirebaseOptions`)
  - Hive
  - Permissions (location, camera, mic, storage, notifications on non-web)
  - Services: `LocationService.initialize`, `NotificationService.initialize`, `OfflineService.initialize`
  - Riverpod `ProviderScope` and `MaterialApp.router`
- Auth token sync begins via `ref.watch(authTokenSyncProvider)` in `OceanHazardApp`.

## 5. Authentication Flow
Files: `core/services/auth_service.dart`, `core/providers/auth_provider.dart`, `core/routing/app_router.dart`, `features/auth/...`

### 5.1 Control Flow (High-level)
1) App starts → Firebase initialized
2) Router checks auth state → redirects to `/login` or `/dashboard`
3) User signs in (email/password or Google)
4) Firebase emits new `User` on `authStateChanges`
5) Riverpod `authProvider` updates; token sync provider fetches ID token and sets `ApiService` header
6) Router redirect takes user to `/dashboard`

### 5.2 Sequence (Email/Password)
```
LoginScreen._signInWithEmail
  → AuthService.signInWithEmail
    → FirebaseAuth.signInWithEmailAndPassword
      → on success: returns Firebase User
  → Router: go('/dashboard')
```

### 5.3 Sequence (Google Sign-in)
```
Login/Register Screen._signInWithGoogle
  → AuthService.signInWithGoogle
    → Web: FirebaseAuth.signInWithPopup(GoogleAuthProvider())
    → Mobile/Desktop: FirebaseAuth.signInWithProvider(GoogleAuthProvider())
      → on success: returns Firebase User
  → Router: go('/dashboard')
```

### 5.4 Providers
- `authProvider: StreamProvider<User?>` bridges Firebase `authStateChanges`
- `currentUserProvider: Provider<UserModel?>` maps Firebase `User` → `UserModel`
- `authTokenSyncProvider: Provider<void>` listens to `authProvider` and:
  - On login: `user.getIdToken()` → `ApiService.setAuthToken(<token>)`
  - On logout/error: `ApiService.clearAuthToken()`

### 5.5 Routing Gating
- `app_router.dart` redirects based on `authProvider`:
  - Not logged in and not on auth routes → `/login`
  - Logged in and on auth routes → `/dashboard`

## 6. API Integration
File: `core/services/api_service.dart`
- Configures `Dio` with base URL and timeouts
- Endpoints:
  - Reports: list, get, create, update, delete, verify
  - Social media posts: filter by platform, sentiment, hazard
  - Analytics: range and region filters
  - Hotspots: geo/time filters
  - Media upload: multipart form
  - Health check
- Auth header management:
  - `setAuthToken(token)` sets `Authorization: Bearer <token>`
  - `clearAuthToken()` removes the header

## 7. Device Services
- `LocationService`: initializes location, checks permissions, exposes current location
- `NotificationService`: initializes local notifications (non-web), schedules/shows alerts
- `OfflineService`: initializes local caches (Hive), manages offline-first flows

## 8. Data Models
- `UserModel`: maps Firebase `User` to app model; includes role flags
- `ReportModel`: hazard type, status, metadata, media
- `SocialMediaPost`: platform, sentiment, hazard-related flags

## 9. UI Flows
### 9.1 Login
- Email/password validation, obscured password toggle
- Google sign-in button
- Link to register, forgot password placeholder

### 9.2 Register
- Full name, email, password/confirm validation
- Google sign-in button

### 9.3 Dashboard and Features
- Post-login, user lands on `/dashboard` and can navigate to map, reports, social feed, profile, settings

## 10. Error Handling
- Auth: Firebase exceptions normalized to user-friendly messages in `AuthService._handleAuthException`
- API: exceptions rethrown with contextual messages
- UI: SnackBars surface failures in auth screens

## 11. Security & Privacy
- Firebase ID token appended to API requests on login
- Ensure Firebase Console is configured:
  - Android: Add SHA-1/SHA-256
  - iOS: URL schemes with reversed client ID
  - Web: Authorized domains include hosting origin

## 12. Build & Platform Notes
- Android: configure `google-services.json`, app-level gradle set up
- iOS: `Info.plist` for URL schemes, push permissions if used
- Web: `web/index.html` includes Firebase scripts via Flutter; domains set in Firebase

## 13. Control Flow Diagrams (ASCII)

### 13.1 App Bootstrap
```
main() ──> Firebase.initializeApp
       ├─> Hive.initFlutter
       ├─> _requestPermissions (mobile/desktop)
       ├─> LocationService.initialize
       ├─> NotificationService.initialize (non-web)
       └─> OfflineService.initialize

OceanHazardApp.build
  └─> watch(authTokenSyncProvider)
      └─> listen(authProvider) → set/clear ApiService token
```

### 13.2 Auth + Routing
```
authProvider (Stream<User?>)
   │
   ├─> app_router redirect
   │     ├─ not logged in → /login
   │     └─ logged in → /dashboard
   │
   └─> authTokenSyncProvider
         ├─ on login: getIdToken → ApiService.setAuthToken
         └─ on logout/error: ApiService.clearAuthToken
```

## 14. Local Development
- Flutter: `flutter clean && flutter pub get`
- Run: `flutter run -d chrome` or `-d android`/`-d ios`
- Lints: configured via `analysis_options.yaml`

## 15. Future Enhancements
- Forgot password screen (uses `AuthService.resetPassword`)
- Role-based route guards (official/analyst/admin)
- Background sync for offline reports
- Push notifications for verified hazards


