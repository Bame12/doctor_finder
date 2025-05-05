import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:doctor_finder_flutter/screens/splash_screen.dart';
import 'package:doctor_finder_flutter/screens/auth/auth_screen.dart';
import 'package:doctor_finder_flutter/screens/home/home_screen.dart';
import 'package:doctor_finder_flutter/screens/doctor/doctor_detail_screen.dart';
import 'package:doctor_finder_flutter/screens/appointment/appointment_screen.dart';
import 'package:doctor_finder_flutter/screens/doctor/reviews_screen.dart';
import 'package:doctor_finder_flutter/screens/profile/profile_screen.dart';
import 'package:doctor_finder_flutter/screens/about/about_screen.dart';
import 'package:doctor_finder_flutter/widgets/common/bottom_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: ${state.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),

    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        ShellRoute(
          navigatorKey: _homeNavigatorKey,
          builder: (context, state, child) => child,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'doctor/:id',
                  builder: (context, state) {
                    final doctorId = state.pathParameters['id']!;
                    return DoctorDetailScreen(doctorId: doctorId);
                  },
                  routes: [
                    GoRoute(
                      path: 'appointment',
                      builder: (context, state) {
                        final doctorId = state.pathParameters['id']!;
                        return AppointmentScreen(doctorId: doctorId);
                      },
                    ),
                    GoRoute(
                      path: 'reviews',
                      builder: (context, state) {
                        final doctorId = state.pathParameters['id']!;
                        return ReviewsScreen(doctorId: doctorId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        ShellRoute(
          navigatorKey: _profileNavigatorKey,
          builder: (context, state, child) => child,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const MainBottomNavBar(),
    );
  }
}