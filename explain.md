# Dindo's Restaurant — What We Built and Why (Phase 1)

This document explains everything we did from the very beginning, in plain language.

---

## The Big Picture

We are building a mobile ordering system for Dindo's Restaurant. The app has two types of users:

- **Customer** — browses the menu, places orders, tracks delivery
- **Admin/Staff** — manages the menu, accepts orders, updates order status

We are building it using **Flutter** (one codebase for Android and iOS) and **Firebase** (Google's cloud platform for storing data and handling login).

We are following the **RAD model** — build one phase at a time, test it, then move to the next. Phase 1 is the foundation: users can register, log in, and be sent to the right screen based on their role.

---

## Step 1 — The Flutter Project

Flutter was already scaffolded (the blank starter project). We did not create a new project from scratch. We just modified the existing files.

Flutter uses **Dart** as its programming language. The app is structured like this:

```
lib/                  ← all your Dart code lives here
android/              ← Android-specific build files
pubspec.yaml          ← the list of packages your app needs (like package.json in Node)
```

---

## Step 2 — Adding Packages (pubspec.yaml)

Think of packages as ready-made tools you plug into your app instead of writing everything yourself.

We added these to [pubspec.yaml](pubspec.yaml):

| Package | What it does |
|---|---|
| `firebase_core` | Required by all Firebase packages — starts the Firebase connection |
| `firebase_auth` | Handles login, registration, logout |
| `cloud_firestore` | The database — stores users, menu items, orders |
| `firebase_storage` | Stores image files (menu item photos, GCash receipts) |
| `firebase_messaging` | Push notifications (used in a later phase) |
| `flutter_riverpod` | State management — shares data between screens cleanly |
| `image_picker` | Lets the user pick a photo from their phone gallery or camera |
| `cached_network_image` | Downloads and caches images from the internet efficiently |
| `uuid` | Generates unique IDs for orders |
| `intl` | Formats dates and currency (e.g. "June 19, 2026" or "₱120.00") |

---

## Step 3 — Android Configuration

Android needs to know the identity of your app. We set this in [android/app/build.gradle.kts](android/app/build.gradle.kts):

```
applicationId = "com.dindos.restaurant"
```

This is like a unique username for your app on the Google Play Store and on Firebase. It must match exactly what you registered in the Firebase console.

We also made sure the **Google Services plugin** (which connects Android to Firebase) is NOT manually added here — instead it gets added automatically when you run `flutterfire configure`. Adding it early caused a build error because it looks for a config file that doesn't exist yet.

---

## Step 4 — Firebase Setup (the Cloud Side)

Firebase is a cloud platform by Google. Before the app can connect to it, you need to:

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable three services:
   - **Authentication** (Email/Password) — so users can register and log in
   - **Firestore Database** — the database that stores all app data
   - **Storage** — where images get uploaded

### What is Firestore?

Firestore is a **NoSQL database**. Instead of tables and rows like MySQL, it uses **collections** and **documents** — like folders and files.

Our database has three collections:

```
users/
  {uid}/              ← one document per user
    name: "Juan"
    email: "juan@gmail.com"
    role: "customer"  ← or "admin"
    phone: "09..."
    createdAt: ...

menuItems/
  {id}/               ← one document per menu item
    name: "Adobo"
    price: 120
    category: "Main Course"
    available: true
    imageUrl: "https://..."

orders/
  {id}/               ← one document per order
    customerId: "abc123"
    items: [...]      ← snapshot of what was ordered + prices at time of order
    total: 360
    status: "Pending"
    paymentMethod: "gcash"
```

---

## Step 5 — Connecting Flutter to Firebase (flutterfire configure)

After creating the Firebase project and enabling the services, we ran a tool called **FlutterFire CLI**:

```
dart pub global run flutterfire_cli:flutterfire configure
```

This tool:
1. Logged into your Firebase account
2. Found your `dindos-restaurant` project
3. Generated two important files:
   - `lib/firebase_options.dart` — tells the Flutter app how to connect to Firebase (contains API keys, project IDs, etc.)
   - `android/app/google-services.json` — tells the Android build system the same thing

Before running this, we had a placeholder `firebase_options.dart` that just showed a helpful error message if someone tried to run the app without configuring Firebase first.

---

## Step 6 — The App Theme (app_theme.dart)

We created [lib/utils/app_theme.dart](lib/utils/app_theme.dart) to define the restaurant's visual style:

- **Primary color:** Deep red (`#B71C1C`) — used for buttons, headers, the splash screen
- **Secondary color:** Amber (`#FF8F00`) — used for accents
- **Background color:** Warm off-white (`#FFF8F0`) — soft, food-friendly

All screens import this theme so the colors stay consistent across the whole app.

---

## Step 7 — The User Model (user_model.dart)

[lib/models/user_model.dart](lib/models/user_model.dart) is a Dart class that represents a user.

Think of it as a "shape" that matches the structure of a Firestore document in the `users/` collection.

```
UserModel {
  uid       ← the unique ID Firebase gives every user
  name
  email
  phone
  role      ← "customer" or "admin"
  createdAt
}
```

It has two important methods:
- `fromFirestore(doc)` — reads a Firestore document and converts it into a `UserModel` object your Dart code can use
- `toMap()` — converts a `UserModel` back into a plain map so you can save it to Firestore

---

## Step 8 — The Auth Service (auth_service.dart)

[lib/services/auth_service.dart](lib/services/auth_service.dart) is a class that handles all login-related actions. It talks to Firebase so the rest of your app doesn't have to.

It has four methods:

| Method | What it does |
|---|---|
| `signUp(name, email, password, phone)` | Creates a Firebase Auth account AND writes a document to `users/{uid}` with `role: 'customer'` |
| `signIn(email, password)` | Logs the user in via Firebase Auth |
| `signOut()` | Logs the user out |
| `getUserModel(uid)` | Reads `users/{uid}` from Firestore and returns a `UserModel` |

**Important security note:** New users are always assigned `role: 'customer'` by the code. There is no way for a user to register as an admin. Admin accounts are created manually in the Firebase Console.

---

## Step 9 — Riverpod Providers (auth_provider.dart)

[lib/providers/auth_provider.dart](lib/providers/auth_provider.dart) uses **Riverpod** to share data across the app.

Riverpod is a state management library. Think of providers as shared "watchers" — any screen can listen to them and automatically rebuild when the data changes.

We created three providers:

### `authServiceProvider`
Just makes the `AuthService` available anywhere in the app. Not reactive.

### `authStateProvider`
Watches Firebase's login stream. It emits:
- `null` → no one is logged in
- `User` → someone is logged in

Any widget that watches this automatically reacts when a user logs in or out.

### `currentUserProvider`
Once a user is logged in, this fetches their Firestore document and returns the full `UserModel` (including their `role`). This is what the app uses to decide whether to show the customer screen or the admin screen.

---

## Step 10 — How the App Starts (main.dart)

[lib/main.dart](lib/main.dart) is the entry point of the entire app. Here is what happens when you tap the app icon:

```
1. Flutter starts
2. Firebase is initialized using the config from firebase_options.dart
3. Riverpod's ProviderScope wraps the whole app (this enables all providers)
4. The app shows AuthWrapper
```

### AuthWrapper
Watches `authStateProvider`:
- If Firebase says **no user** → shows `LoginScreen`
- If Firebase says **user is logged in** → shows `RoleRouter`
- While loading → shows the red splash screen

### RoleRouter
Watches `currentUserProvider` (fetches the user's role from Firestore):
- If `role == 'admin'` → shows `AdminHomeScreen`
- Otherwise → shows `CustomerHomeScreen`
- While loading → shows the splash screen

This means the app **automatically navigates** when you log in or log out — no manual navigation code needed.

---

## Step 11 — Login Screen (login_screen.dart)

[lib/screens/auth/login_screen.dart](lib/screens/auth/login_screen.dart) shows:
- Dindo's restaurant logo and name
- Email field
- Password field (with show/hide toggle)
- "Sign In" button
- Error banner if login fails (e.g. "Invalid email or password.")
- Link to the Register screen

When the user taps Sign In, it calls `AuthService.signIn()`. If successful, `authStateProvider` automatically detects the login and `AuthWrapper` navigates the user to their home screen.

---

## Step 12 — Register Screen (register_screen.dart)

[lib/screens/auth/register_screen.dart](lib/screens/auth/register_screen.dart) shows:
- Full Name, Email, Phone Number, Password, Confirm Password fields
- "Create Account" button
- Error banner for common mistakes (email already taken, weak password, etc.)

When registration succeeds, it calls `AuthService.signUp()` which:
1. Creates the Firebase Auth account
2. Writes the user document to Firestore with `role: 'customer'`

Then `AuthWrapper` detects the new login and automatically navigates to `CustomerHomeScreen`.

---

## Step 13 — Home Screens (placeholders for now)

We created two placeholder home screens:

- [lib/screens/customer/customer_home_screen.dart](lib/screens/customer/customer_home_screen.dart) — shows a welcome message and a logout button. Will become the full menu browsing experience in Phase 3.
- [lib/screens/admin/admin_home_screen.dart](lib/screens/admin/admin_home_screen.dart) — shows three feature cards (Menu, Orders, Delivery). Will become the full admin dashboard in Phase 2.

These placeholders confirm that role-based routing is working correctly before we build the real content.

---

## Step 14 — Firestore Security Rules (firestore.rules)

[firestore.rules](firestore.rules) is a set of rules deployed to Firebase that control who can read and write what data.

This is critical for security — without these rules, anyone with your API key could read or modify all data.

Here is a summary of the rules:

| Collection | Who can read | Who can write |
|---|---|---|
| `users/{uid}` | The user themselves OR an admin | Users can create their own doc (with `role: 'customer'` only). Users can update their own profile (but cannot change their role). Admins can delete. |
| `menuItems/{id}` | Any logged-in user | Admins only |
| `orders/{id}` | The customer who placed it OR an admin | Customers can create orders for themselves. Admins can update order status. Nobody can delete orders. |

The rules use helper functions like `isAdmin()` which reads the user's role directly from Firestore — this means a user cannot fake being an admin by modifying data on their phone.

---

## Step 15 — Deploying the Rules

The security rules file lives in our project folder but needs to be uploaded to Firebase to take effect.

We fixed `firebase.json` to tell Firebase where the rules file is, then ran:

```
npx firebase-tools deploy --only firestore:rules
```

This uploads `firestore.rules` to the cloud. From that point on, every read/write to the database is checked against those rules.

---

## How Everything Connects

```
User opens app
    ↓
main.dart initializes Firebase
    ↓
AuthWrapper checks: is anyone logged in? (authStateProvider)
    ↓                              ↓
   No → LoginScreen           Yes → RoleRouter
           ↓                          ↓
    Register / Login        Fetch role from Firestore (currentUserProvider)
           ↓                    ↓               ↓
    Firebase Auth          role=admin      role=customer
    creates session            ↓               ↓
           ↓             AdminHomeScreen  CustomerHomeScreen
    AuthWrapper detects
    login → RoleRouter
```

---

## What's Next (Phase 2)

Now that the foundation is working, Phase 2 will build the **Menu & Inventory** system:
- Admin can add, edit, and delete menu items
- Admin can mark items as sold out
- Admin can upload a photo for each menu item
- Customers can see the live menu (built in Phase 3)
