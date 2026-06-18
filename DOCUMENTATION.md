# Dindo's Restaurant — Build Log

> **Project:** Dindo's Restaurant Mobile Ordering & Management System  
> **Capstone model:** Rapid Application Development (RAD)  
> **Stack:** Flutter · Firebase (Auth, Firestore, Storage, Messaging) · Riverpod  
> **Android App ID:** `com.dindos.restaurant`

---

## Phase 1 — Foundation Setup
**Date:** 2026-06-19  
**Feature:** Firebase integration, Authentication, Role-based routing

### What was done
Bootstrapped the entire project foundation from the blank Flutter scaffold:

1. Added all Firebase and Riverpod dependencies to `pubspec.yaml`.
2. Updated Android Gradle files to raise `minSdk` to 23 (required by Firebase) and registered the Google Services plugin.
3. Created `lib/firebase_options.dart` — a placeholder that throws a helpful error until the developer runs `flutterfire configure`.
4. Created the app theme (`AppTheme`) with a warm deep-red / amber restaurant palette.
5. Created `UserModel` — maps `users/{uid}` Firestore documents.
6. Created `AuthService` — wraps Firebase Auth (sign up, sign in, sign out) and writes new users to Firestore with `role: 'customer'`.
7. Created Riverpod providers: `authServiceProvider`, `authStateProvider` (stream), `currentUserProvider` (future).
8. Rewrote `main.dart`:  
   - Initialises Firebase before `runApp`.  
   - Wraps the entire app in `ProviderScope`.  
   - `AuthWrapper` → watches `authStateProvider`; shows `LoginScreen` when signed out, `RoleRouter` when signed in.  
   - `RoleRouter` → reads `currentUserProvider`; routes `admin` to `AdminHomeScreen`, `customer` to `CustomerHomeScreen`.
9. Created `LoginScreen` — email/password form with inline Firebase error messages.
10. Created `RegisterScreen` — name, email, phone, password, confirm-password form; always assigns `role: 'customer'`.
11. Created placeholder `CustomerHomeScreen` and `AdminHomeScreen` (ready for Phase 2/5).
12. Created `firestore.rules` with enforced access control:
    - Customers: read/write only their own data, create orders only for themselves.
    - Admins: full read on users/orders, full write on menuItems, can update any order.
    - Menu items: read by any authenticated user; write by admin only.

### Why
Establishes the secure, role-aware foundation that every subsequent phase builds on (RAD Phase 1 goal).

### Files created or changed
| File | Action |
|---|---|
| `pubspec.yaml` | Updated — added Firebase, Riverpod, image_picker, cached_network_image, uuid, intl |
| `android/app/build.gradle.kts` | Updated — minSdk 23, applicationId `com.dindos.restaurant`, Google Services plugin |
| `android/settings.gradle.kts` | Updated — added Google Services plugin declaration |
| `lib/main.dart` | Rewritten — Firebase init, ProviderScope, AuthWrapper, RoleRouter |
| `lib/firebase_options.dart` | Created — placeholder (replace with `flutterfire configure` output) |
| `lib/utils/app_theme.dart` | Created |
| `lib/models/user_model.dart` | Created |
| `lib/services/auth_service.dart` | Created |
| `lib/providers/auth_provider.dart` | Created |
| `lib/screens/auth/login_screen.dart` | Created |
| `lib/screens/auth/register_screen.dart` | Created |
| `lib/screens/customer/customer_home_screen.dart` | Created |
| `lib/screens/admin/admin_home_screen.dart` | Created |
| `firestore.rules` | Created |
| `DOCUMENTATION.md` | Created (this file) |

### Commands to run before first build

```bash
# 1. Install FlutterFire CLI (once per machine)
dart pub global activate flutterfire_cli

# 2. Install Flutter packages
flutter pub get

# 3. Configure Firebase (creates lib/firebase_options.dart + google-services.json)
#    You need a Firebase project at console.firebase.google.com first.
#    Enable: Authentication (Email/Password), Cloud Firestore, Cloud Storage.
flutterfire configure

# 4. Deploy Firestore security rules
firebase deploy --only firestore:rules

# 5. Create the admin account manually
#    In Firebase Console → Authentication → Add user (email + password)
#    Then in Firestore → users/{that-uid} → set role: "admin"

# 6. Run the app
flutter run
```

---

## How to test Phase 1

1. Run `flutter run` on a connected device/emulator.
2. The splash screen appears while Firebase initialises.
3. **Register** a new customer account → confirm you land on `CustomerHomeScreen`.
4. **Sign out** → confirm you return to `LoginScreen`.
5. **Admin test**: In Firebase Console, find the admin user's UID, open Firestore → `users/{uid}`, change `role` to `"admin"`. Sign in as that user → confirm you land on `AdminHomeScreen`.
6. Try signing in with wrong credentials → confirm the error banner appears inline.

---

*Next phase: Phase 2 — Menu & Inventory Management (admin CRUD, sold-out toggle, image upload).*
