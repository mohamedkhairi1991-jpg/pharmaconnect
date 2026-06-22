import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_admin/app/router/admin_router.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

void main() {
  const AsyncValue<AuthSessionState> authenticated = AsyncData(
    AuthSessionState.authenticated(userId: 'user-id', email: null),
  );

  test('signed-out users are sent to admin sign in', () {
    expect(
      adminAuthRedirect(
        location: adminAuthenticatedPath,
        authState: AsyncData(const AuthSessionState.signedOut()),
        principal: const AsyncData<SessionPrincipal?>(null),
      ),
      adminSignInPath,
    );
  });

  test('password recovery event is sent to reset password', () {
    expect(
      adminAuthRedirect(
        location: adminSignInPath,
        authState: AsyncData(
          const AuthSessionState.passwordRecovery(
            userId: 'user-id',
            email: null,
          ),
        ),
        principal: const AsyncData<SessionPrincipal?>(null),
      ),
      adminResetPasswordPath,
    );
  });

  test('non-admin principals are denied admin access', () {
    expect(
      adminAuthRedirect(
        location: adminAuthenticatedPath,
        authState: AsyncData(
          const AuthSessionState.authenticated(userId: 'user-id', email: null),
        ),
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.companyUser,
            profile: null,
          ),
        ),
      ),
      adminUnauthorizedPath,
    );
  });

  test('catalog review allows permitted administrator access', () {
    expect(
      adminAuthRedirect(
        location: adminCatalogReviewPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.administrator,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncData(
          CatalogAccessState(CatalogAudience.administrator),
        ),
      ),
      isNull,
    );
  });

  test('catalog review denies unauthorized and non-admin access', () {
    expect(
      adminAuthRedirect(
        location: adminCatalogReviewPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.administrator,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncData(
          CatalogAccessState(CatalogAudience.roleIneligible),
        ),
      ),
      adminUnauthorizedPath,
    );

    expect(
      adminAuthRedirect(
        location: adminCatalogReviewPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.companyUser,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncData(
          CatalogAccessState(CatalogAudience.administrator),
        ),
      ),
      adminUnauthorizedPath,
    );
  });

  test('loading catalog access uses session loading and preserves target', () {
    expect(
      adminAuthRedirect(
        location: adminCatalogReviewPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.administrator,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncLoading<CatalogAccessState>(),
      ),
      '$adminSessionLoadingPath?catalogTarget=%2Fcatalog%2Freview',
    );
  });

  test('catalog review loading does not redirect loop', () {
    expect(
      adminAuthRedirect(
        location: adminSessionLoadingPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.administrator,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncLoading<CatalogAccessState>(),
        pendingCatalogLocation: adminCatalogReviewPath,
      ),
      isNull,
    );

    expect(
      adminAuthRedirect(
        location: adminSessionLoadingPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.administrator,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncData(
          CatalogAccessState(CatalogAudience.administrator),
        ),
        pendingCatalogLocation: adminCatalogReviewPath,
      ),
      adminCatalogReviewPath,
    );
  });

  test('previous administrator access is not retained after access change', () {
    const AsyncValue<SessionPrincipal?> administrator = AsyncData(
      SessionPrincipal(kind: SessionPrincipalKind.administrator, profile: null),
    );

    expect(
      adminAuthRedirect(
        location: adminCatalogReviewPath,
        authState: authenticated,
        principal: administrator,
        catalogAccess: const AsyncData(
          CatalogAccessState(CatalogAudience.administrator),
        ),
      ),
      isNull,
    );

    expect(
      adminAuthRedirect(
        location: adminCatalogReviewPath,
        authState: authenticated,
        principal: administrator,
        catalogAccess: const AsyncData(
          CatalogAccessState(CatalogAudience.roleIneligible),
        ),
      ),
      adminUnauthorizedPath,
    );
  });

  test('catalog review does not loop while auth or principal loads', () {
    expect(
      adminAuthRedirect(
        location: adminCatalogReviewPath,
        authState: const AsyncLoading<AuthSessionState>(),
        principal: const AsyncLoading<SessionPrincipal?>(),
      ),
      adminSessionLoadingPath,
    );
    expect(
      adminAuthRedirect(
        location: adminSessionLoadingPath,
        authState: const AsyncLoading<AuthSessionState>(),
        principal: const AsyncLoading<SessionPrincipal?>(),
      ),
      isNull,
    );
    expect(
      adminAuthRedirect(
        location: adminCatalogReviewPath,
        authState: authenticated,
        principal: const AsyncLoading<SessionPrincipal?>(),
      ),
      adminSessionLoadingPath,
    );
    expect(
      adminAuthRedirect(
        location: adminSessionLoadingPath,
        authState: authenticated,
        principal: const AsyncLoading<SessionPrincipal?>(),
      ),
      isNull,
    );
  });
}
