import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final GoRouter mobileRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SizedBox.shrink();
      },
    ),
  ],
);
