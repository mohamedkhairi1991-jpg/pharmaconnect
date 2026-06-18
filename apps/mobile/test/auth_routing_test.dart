import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';
import 'package:pharmaconnect_mobile/app/router/mobile_router.dart';

void main() {
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
}
