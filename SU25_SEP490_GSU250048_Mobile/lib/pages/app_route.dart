import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/commmon_pages/login_page.dart';
import 'package:mobile/pages/commmon_pages/profile_page.dart';
import 'package:mobile/pages/customer_pages/provider_page.dart';
import 'package:mobile/pages/customer_pages/screens/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: LoginPage.path,
    routes: [
      GoRoute(
        path: LoginPage.path,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      ShellRoute(
        builder: (context, state, child) => ProviderHomePage(child: child),
          routes: [
            GoRoute(
              path: '/customer/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/customer/search',
              builder: (context, state) => const HomeScreen(),
            ),GoRoute(
              path: '/customer/history',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ]
      ),
      // ShellRoute(
      //   builder: (context, state, child) => ProviderHomePage(child: child),
      //   routes: [
      //
      //   ]
      // )
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Page not found: ${state.error}'),
        ),
      );
    },
  );
}
