import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_admin/features/authentication/presentation/forgot_password_page.dart';
import 'package:pharmaconnect_admin/features/authentication/presentation/reset_password_page.dart';
import 'package:pharmaconnect_admin/features/authentication/presentation/session_pages.dart';
import 'package:pharmaconnect_admin/features/authentication/presentation/sign_in_page.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

const String adminSignInPath = '/auth/sign-in';
const String adminForgotPasswordPath = '/auth/forgot-password';
const String adminCallbackPath = '/auth/callback';
const String adminResetPasswordPath = '/auth/reset-password';
const String adminSessionLoadingPath = '/session/loading';
const String adminUnauthorizedPath = '/session/unauthorized';
const String adminAccountUnavailablePath = '/session/unavailable';
const String adminAuthenticatedPath = '/session';

final Provider<GoRouter> adminRouterProvider = Provider<GoRouter>((Ref ref) {
  late final GoRouter router;
  router = GoRouter(
    initialLocation: adminSessionLoadingPath,
    redirect: (context, state) => adminAuthRedirect(
      location: state.matchedLocation,
      authState: ref.read(authStateProvider),
      principal: ref.read(sessionPrincipalProvider),
    ),
    routes: <RouteBase>[
      GoRoute(
        path: adminSignInPath,
        builder: (context, state) => const AdminSignInPage(),
      ),
      GoRoute(
        path: adminForgotPasswordPath,
        builder: (context, state) => const AdminForgotPasswordPage(),
      ),
      GoRoute(
        path: adminCallbackPath,
        builder: (context, state) => const AdminSessionLoadingPage(),
      ),
      GoRoute(
        path: adminResetPasswordPath,
        builder: (context, state) => const AdminResetPasswordPage(),
      ),
      GoRoute(
        path: adminSessionLoadingPath,
        builder: (context, state) => const AdminSessionLoadingPage(),
      ),
      GoRoute(
        path: adminUnauthorizedPath,
        builder: (context, state) => const AdminUnauthorizedPage(),
      ),
      GoRoute(
        path: adminAccountUnavailablePath,
        builder: (context, state) => const AdminAccountUnavailablePage(),
      ),
      GoRoute(
        path: adminAuthenticatedPath,
        builder: (context, state) => const AdminAuthenticatedShellPage(),
      ),
    ],
  );

  ref
    ..listen(authStateProvider, (previous, next) => router.refresh())
    ..listen(sessionPrincipalProvider, (previous, next) => router.refresh())
    ..onDispose(router.dispose);

  return router;
});

String? adminAuthRedirect({
  required String location,
  required AsyncValue<AuthSessionState> authState,
  required AsyncValue<SessionPrincipal?> principal,
}) {
  const Set<String> publicPaths = <String>{
    adminSignInPath,
    adminForgotPasswordPath,
    adminCallbackPath,
  };

  if (authState.isLoading) {
    return location == adminSessionLoadingPath ? null : adminSessionLoadingPath;
  }
  if (authState.hasError) {
    return location == adminSignInPath ? null : adminSignInPath;
  }

  final AuthSessionState state = authState.requireValue;
  if (state.phase == AuthSessionPhase.passwordRecovery) {
    return location == adminResetPasswordPath ? null : adminResetPasswordPath;
  }
  if (!state.isAuthenticated) {
    return publicPaths.contains(location) ? null : adminSignInPath;
  }

  if (principal.isLoading) {
    return location == adminSessionLoadingPath ? null : adminSessionLoadingPath;
  }
  if (principal.hasError || principal.value == null) {
    return location == adminAccountUnavailablePath
        ? null
        : adminAccountUnavailablePath;
  }

  final String destination = switch (principal.requireValue!.kind) {
    SessionPrincipalKind.administrator => adminAuthenticatedPath,
    SessionPrincipalKind.healthcareProfessional ||
    SessionPrincipalKind.companyUser => adminUnauthorizedPath,
    SessionPrincipalKind.pending ||
    SessionPrincipalKind.suspended ||
    SessionPrincipalKind.archived ||
    SessionPrincipalKind.profileUnavailable => adminAccountUnavailablePath,
  };

  return location == destination ? null : destination;
}
