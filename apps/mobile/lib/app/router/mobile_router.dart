import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/check_email_page.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/forgot_password_page.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/reset_password_page.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/session_pages.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/sign_in_page.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/sign_up_page.dart';

const String mobileSignInPath = '/auth/sign-in';
const String mobileSignUpPath = '/auth/sign-up';
const String mobileForgotPasswordPath = '/auth/forgot-password';
const String mobileCheckEmailPath = '/auth/check-email';
const String mobileCallbackPath = '/auth/callback';
const String mobileResetPasswordPath = '/auth/reset-password';
const String mobileSessionLoadingPath = '/session/loading';
const String mobileSessionStatusPath = '/session/status';
const String mobileAccountUnavailablePath = '/session/unavailable';
const String mobileAuthenticatedPath = '/session';

final Provider<GoRouter> mobileRouterProvider = Provider<GoRouter>((Ref ref) {
  late final GoRouter router;
  router = GoRouter(
    initialLocation: mobileSessionLoadingPath,
    redirect: (context, state) => mobileAuthRedirect(
      location: state.matchedLocation,
      authState: ref.read(authStateProvider),
      principal: ref.read(sessionPrincipalProvider),
    ),
    routes: <RouteBase>[
      GoRoute(
        path: mobileSignInPath,
        builder: (context, state) => const MobileSignInPage(),
      ),
      GoRoute(
        path: mobileSignUpPath,
        builder: (context, state) => const MobileSignUpPage(),
      ),
      GoRoute(
        path: mobileForgotPasswordPath,
        builder: (context, state) => const MobileForgotPasswordPage(),
      ),
      GoRoute(
        path: mobileCheckEmailPath,
        builder: (context, state) =>
            MobileCheckEmailPage(initialEmail: state.extra as String?),
      ),
      GoRoute(
        path: mobileCallbackPath,
        builder: (context, state) => const MobileSessionLoadingPage(),
      ),
      GoRoute(
        path: mobileResetPasswordPath,
        builder: (context, state) => const MobileResetPasswordPage(),
      ),
      GoRoute(
        path: mobileSessionLoadingPath,
        builder: (context, state) => const MobileSessionLoadingPage(),
      ),
      GoRoute(
        path: mobileSessionStatusPath,
        builder: (context, state) => const MobileSessionStatusPage(),
      ),
      GoRoute(
        path: mobileAccountUnavailablePath,
        builder: (context, state) => const MobileAccountUnavailablePage(),
      ),
      GoRoute(
        path: mobileAuthenticatedPath,
        builder: (context, state) => const MobileAuthenticatedShellPage(),
      ),
    ],
  );

  ref
    ..listen(authStateProvider, (previous, next) => router.refresh())
    ..listen(sessionPrincipalProvider, (previous, next) => router.refresh())
    ..onDispose(router.dispose);

  return router;
});

String? mobileAuthRedirect({
  required String location,
  required AsyncValue<AuthSessionState> authState,
  required AsyncValue<SessionPrincipal?> principal,
}) {
  const Set<String> publicPaths = <String>{
    mobileSignInPath,
    mobileSignUpPath,
    mobileForgotPasswordPath,
    mobileCheckEmailPath,
    mobileCallbackPath,
  };

  if (authState.isLoading) {
    return location == mobileSessionLoadingPath
        ? null
        : mobileSessionLoadingPath;
  }
  if (authState.hasError) {
    return location == mobileSignInPath ? null : mobileSignInPath;
  }

  final AuthSessionState state = authState.requireValue;
  if (state.phase == AuthSessionPhase.passwordRecovery) {
    return location == mobileResetPasswordPath ? null : mobileResetPasswordPath;
  }
  if (!state.isAuthenticated) {
    return publicPaths.contains(location) ? null : mobileSignInPath;
  }

  if (principal.isLoading) {
    return location == mobileSessionLoadingPath
        ? null
        : mobileSessionLoadingPath;
  }
  if (principal.hasError || principal.value == null) {
    return location == mobileAccountUnavailablePath
        ? null
        : mobileAccountUnavailablePath;
  }

  final String destination = switch (principal.requireValue!.kind) {
    SessionPrincipalKind.pending => mobileSessionStatusPath,
    SessionPrincipalKind.suspended ||
    SessionPrincipalKind.archived ||
    SessionPrincipalKind.profileUnavailable => mobileAccountUnavailablePath,
    SessionPrincipalKind.healthcareProfessional ||
    SessionPrincipalKind.companyUser => mobileAuthenticatedPath,
    SessionPrincipalKind.administrator => mobileAccountUnavailablePath,
  };

  return location == destination ? null : destination;
}
