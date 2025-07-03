import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/commmon_pages/login_page.dart';
import 'package:mobile/pages/commmon_pages/profile_page.dart';
import 'package:mobile/pages/customer_pages/provider_page.dart';

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
              path: '/provider/home',
              builder: (context, state) => const ProfilePage(),
            ),
          ]
      )
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
