import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/check_email_page.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/forgot_password_page.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/reset_password_page.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/session_pages.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/sign_in_page.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/sign_up_page.dart';
import 'package:pharmaconnect_mobile/features/catalog/presentation/catalog_entry_pages.dart';

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
const String mobileOfficialCatalogPath = '/catalog';
const String mobileOfficialCatalogProductPath = '/catalog/products/:productId';
const String mobileCompanyCatalogPath = '/company/catalog';

const String _catalogTargetQueryParameter = 'catalogTarget';

final Provider<GoRouter> mobileRouterProvider = Provider<GoRouter>((Ref ref) {
  late final GoRouter router;
  router = GoRouter(
    initialLocation: mobileSessionLoadingPath,
    redirect: (context, state) => mobileAuthRedirect(
      location: state.uri.path,
      authState: ref.read(authStateProvider),
      principal: ref.read(sessionPrincipalProvider),
      catalogAccess: ref.read(catalogAccessStateProvider),
      pendingCatalogLocation:
          state.uri.queryParameters[_catalogTargetQueryParameter],
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
      GoRoute(
        path: mobileOfficialCatalogPath,
        builder: (context, state) => const MobileOfficialCatalogEntryPage(),
      ),
      GoRoute(
        path: mobileOfficialCatalogProductPath,
        builder: (context, state) => MobileOfficialCatalogProductDetailPage(
          productId: state.pathParameters['productId'] ?? '',
        ),
      ),
      GoRoute(
        path: mobileCompanyCatalogPath,
        builder: (context, state) => const MobileCompanyCatalogEntryPage(),
      ),
    ],
  );

  ref
    ..listen(authStateProvider, (previous, next) => router.refresh())
    ..listen(sessionPrincipalProvider, (previous, next) => router.refresh())
    ..listen(catalogAccessStateProvider, (previous, next) => router.refresh())
    ..onDispose(router.dispose);

  return router;
});

String? mobileAuthRedirect({
  required String location,
  required AsyncValue<AuthSessionState> authState,
  required AsyncValue<SessionPrincipal?> principal,
  AsyncValue<CatalogAccessState>? catalogAccess,
  String? pendingCatalogLocation,
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

  final SessionPrincipalKind principalKind = principal.requireValue!.kind;
  final String destination = switch (principalKind) {
    SessionPrincipalKind.pending => mobileSessionStatusPath,
    SessionPrincipalKind.suspended ||
    SessionPrincipalKind.archived ||
    SessionPrincipalKind.profileUnavailable => mobileAccountUnavailablePath,
    SessionPrincipalKind.healthcareProfessional ||
    SessionPrincipalKind.companyUser => mobileAuthenticatedPath,
    SessionPrincipalKind.administrator => mobileAccountUnavailablePath,
  };

  if (destination != mobileAuthenticatedPath) {
    return location == destination ? null : destination;
  }

  final String? catalogTarget = _catalogTargetForLocation(
    location,
    pendingCatalogLocation,
  );
  if (catalogTarget != null) {
    final AsyncValue<CatalogAccessState> access =
        catalogAccess ?? const AsyncLoading<CatalogAccessState>();
    if (access.isLoading) {
      if (location == mobileSessionLoadingPath) {
        return null;
      }
      return Uri(
        path: mobileSessionLoadingPath,
        queryParameters: <String, String>{
          _catalogTargetQueryParameter: catalogTarget,
        },
      ).toString();
    }
    if (access.hasError) {
      return location == mobileAccountUnavailablePath
          ? null
          : mobileAccountUnavailablePath;
    }

    final bool allowed = switch (catalogTarget) {
      final String target when _isOfficialCatalogLocation(target) =>
        principalKind == SessionPrincipalKind.healthcareProfessional &&
            access.requireValue.canReadOfficialCatalog,
      mobileCompanyCatalogPath =>
        principalKind == SessionPrincipalKind.companyUser &&
            access.requireValue.canReadCompanyWorkflow,
      _ => false,
    };
    if (!allowed) {
      return location == mobileAccountUnavailablePath
          ? null
          : mobileAccountUnavailablePath;
    }
    return location == catalogTarget ? null : catalogTarget;
  }

  if (principalKind == SessionPrincipalKind.healthcareProfessional) {
    final AsyncValue<CatalogAccessState> access =
        catalogAccess ?? const AsyncLoading<CatalogAccessState>();
    if (access.isLoading) {
      return location == mobileSessionLoadingPath
          ? null
          : mobileSessionLoadingPath;
    }
    if (access.hasError || !access.requireValue.canReadOfficialCatalog) {
      return location == mobileAccountUnavailablePath
          ? null
          : mobileAccountUnavailablePath;
    }
    return location == mobileOfficialCatalogPath
        ? null
        : mobileOfficialCatalogPath;
  }

  return location == mobileAuthenticatedPath ? null : mobileAuthenticatedPath;
}

String? _catalogTargetForLocation(
  String location,
  String? pendingCatalogLocation,
) {
  if (location == mobileOfficialCatalogPath ||
      _isOfficialCatalogDetailLocation(location) ||
      location == mobileCompanyCatalogPath) {
    return location;
  }
  if (location == mobileSessionLoadingPath &&
      (pendingCatalogLocation == mobileOfficialCatalogPath ||
          _isOfficialCatalogDetailLocation(pendingCatalogLocation) ||
          pendingCatalogLocation == mobileCompanyCatalogPath)) {
    return pendingCatalogLocation;
  }
  return null;
}

bool _isOfficialCatalogLocation(String location) {
  return location == mobileOfficialCatalogPath ||
      _isOfficialCatalogDetailLocation(location);
}

bool _isOfficialCatalogDetailLocation(String? location) {
  return location != null && location.startsWith('/catalog/products/');
}
