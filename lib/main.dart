import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/employee/employee_home_screen.dart';
import 'screens/rider/rider_home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: DindosApp()));
}

class DindosApp extends StatelessWidget {
  const DindosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dindo's Restaurant",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const LoginScreen();
        return const RoleRouter();
      },
      loading: () => const _SplashScreen(),
      error: (_, _) => const LoginScreen(),
    );
  }
}

class RoleRouter extends ConsumerWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const LoginScreen();
        if (user.role == 'admin') return const AdminHomeScreen();
        if (user.role == 'employee') return const EmployeeHomeScreen();
        if (user.role == 'rider') return const RiderHomeScreen();
        return const CustomerHomeScreen();
      },
      loading: () => const _SplashScreen(),
      error: (_, _) => const LoginScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text(
              "Dindo's Restaurant",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
