import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_admin/app/router/admin_router.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

void main() {
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
}
