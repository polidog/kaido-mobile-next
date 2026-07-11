import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kaido_ui/pages/contact_map_page.dart';
import 'package:kaido_ui/pages/contact_page.dart';
import 'package:kaido_ui/pages/copyright_page.dart';
import 'package:kaido_ui/pages/html_page.dart';
import 'package:kaido_ui/pages/image_page.dart';
import 'package:kaido_ui/pages/info_page.dart';
import 'package:kaido_ui/pages/map_page.dart';
import 'package:kaido_ui/pages/settings_page.dart';
import 'package:kaido_ui/pages/splash_page.dart';
import 'package:kaido_ui/router/kaido_route_paths.dart';

/// Creates the [GoRouter] shared by all Kaido apps.
GoRouter createKaidoRouter({
  String initialLocation = KaidoRoutePaths.home,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: KaidoRoutePaths.home,
        builder: (context, state) => const MapPage(),
      ),
      GoRoute(
        path: KaidoRoutePaths.info,
        builder: (context, state) => InfoPage(
          id: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            path: KaidoRoutePaths.image,
            builder: (context, state) => ImagePage(
              id: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: KaidoRoutePaths.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: KaidoRoutePaths.contact,
        builder: (context, state) => const ContactPage(),
        routes: [
          GoRoute(
            path: KaidoRoutePaths.contactMap,
            builder: (context, state) => const ContactMapPage(),
          ),
        ],
      ),
      GoRoute(
        path: KaidoRoutePaths.html,
        builder: (context, state) => HtmlPage(
          page: state.pathParameters['page']!,
        ),
      ),
      GoRoute(
        path: KaidoRoutePaths.copyright,
        builder: (context, state) => const CopyrightPage(),
      ),
      GoRoute(
        path: KaidoRoutePaths.splash,
        builder: (context, state) => const SplashPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('エラー')),
      body: Center(child: Text('ページが見つかりません: ${state.uri}')),
    ),
  );
}

/// Default [GoRouter] instance for the Kaido apps.
final GoRouter kaidoRouter = createKaidoRouter();
