import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';
import 'package:pharmaconnect_mobile/app/router/mobile_router.dart';

void main() {
  const AsyncValue<AuthSessionState> authenticated = AsyncData(
    AuthSessionState.authenticated(userId: 'user-id', email: null),
  );

  test('signed-out users are sent to mobile sign in', () {
    expect(
      mobileAuthRedirect(
        location: mobileAuthenticatedPath,
        authState: AsyncData(const AuthSessionState.signedOut()),
        principal: const AsyncData<SessionPrincipal?>(null),
      ),
      mobileSignInPath,
    );
  });

  test('password recovery event is sent to reset password', () {
    expect(
      mobileAuthRedirect(
        location: mobileSignInPath,
        authState: AsyncData(
          const AuthSessionState.passwordRecovery(
            userId: 'user-id',
            email: null,
          ),
        ),
        principal: const AsyncData<SessionPrincipal?>(null),
      ),
      mobileResetPasswordPath,
    );
  });

  test('administrator cannot enter the mobile authenticated shell', () {
    expect(
      mobileAuthRedirect(
        location: mobileAuthenticatedPath,
        authState: AsyncData(
          const AuthSessionState.authenticated(userId: 'user-id', email: null),
        ),
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.administrator,
            profile: null,
          ),
        ),
      ),
      mobileAccountUnavailablePath,
    );
  });

  test('official catalog allows approved doctor access', () {
    expect(
      mobileAuthRedirect(
        location: mobileOfficialCatalogPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.healthcareProfessional,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncData(
          CatalogAccessState(CatalogAudience.officialCatalog),
        ),
      ),
      isNull,
    );
  });

  test('official catalog denies pharmacist or unauthorized access', () {
    expect(
      mobileAuthRedirect(
        location: mobileOfficialCatalogPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.healthcareProfessional,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncData(
          CatalogAccessState(CatalogAudience.roleIneligible),
        ),
      ),
      mobileAccountUnavailablePath,
    );
  });

  test('company catalog allows permitted workflow access', () {
    expect(
      mobileAuthRedirect(
        location: mobileCompanyCatalogPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.companyUser,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncData(
          CatalogAccessState(CatalogAudience.companyWorkflow),
        ),
      ),
      isNull,
    );
  });

  test('company catalog denies suspended or unauthorized access', () {
    expect(
      mobileAuthRedirect(
        location: mobileCompanyCatalogPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(kind: SessionPrincipalKind.suspended, profile: null),
        ),
        catalogAccess: const AsyncData(
          CatalogAccessState(CatalogAudience.companyWorkflow),
        ),
      ),
      mobileAccountUnavailablePath,
    );

    expect(
      mobileAuthRedirect(
        location: mobileCompanyCatalogPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.companyUser,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncData(
          CatalogAccessState(CatalogAudience.roleIneligible),
        ),
      ),
      mobileAccountUnavailablePath,
    );
  });

  test('loading catalog access uses session loading and preserves target', () {
    expect(
      mobileAuthRedirect(
        location: mobileOfficialCatalogPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.healthcareProfessional,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncLoading<CatalogAccessState>(),
      ),
      '$mobileSessionLoadingPath?catalogTarget=%2Fcatalog',
    );
  });

  test('guarded catalog loading does not redirect loop', () {
    expect(
      mobileAuthRedirect(
        location: mobileSessionLoadingPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.healthcareProfessional,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncLoading<CatalogAccessState>(),
        pendingCatalogLocation: mobileOfficialCatalogPath,
      ),
      isNull,
    );

    expect(
      mobileAuthRedirect(
        location: mobileSessionLoadingPath,
        authState: authenticated,
        principal: const AsyncData(
          SessionPrincipal(
            kind: SessionPrincipalKind.healthcareProfessional,
            profile: null,
          ),
        ),
        catalogAccess: const AsyncData(
          CatalogAccessState(CatalogAudience.officialCatalog),
        ),
        pendingCatalogLocation: mobileOfficialCatalogPath,
      ),
      mobileOfficialCatalogPath,
    );
  });
}
