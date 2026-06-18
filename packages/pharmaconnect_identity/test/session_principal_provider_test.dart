import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

void main() {
  test('signed-out sessions have no principal', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWithValue(
          const AsyncData(AuthSessionState.signedOut()),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(sessionPrincipalProvider.future), isNull);
  });

  test('active administrators resolve to an administrator principal', () async {
    final DateTime timestamp = DateTime.utc(2026);
    final Profile profile = Profile(
      id: 'profile-id',
      authUserId: 'user-id',
      email: 'admin@example.com',
      role: PlatformRole.admin,
      status: ProfileStatus.active,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWithValue(
          const AsyncData(
            AuthSessionState.authenticated(
              userId: 'user-id',
              email: 'admin@example.com',
            ),
          ),
        ),
        currentProfileProvider.overrideWithValue(AsyncData(profile)),
      ],
    );
    addTearDown(container.dispose);

    final SessionPrincipal? principal = await container.read(
      sessionPrincipalProvider.future,
    );

    expect(principal?.kind, SessionPrincipalKind.administrator);
    expect(principal?.profile, same(profile));
  });

  test('authenticated users without a profile fail closed', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWithValue(
          const AsyncData(
            AuthSessionState.authenticated(
              userId: 'user-id',
              email: 'person@example.com',
            ),
          ),
        ),
        currentProfileProvider.overrideWithValue(
          const AsyncData<Profile?>(null),
        ),
      ],
    );
    addTearDown(container.dispose);

    final SessionPrincipal? principal = await container.read(
      sessionPrincipalProvider.future,
    );

    expect(principal?.kind, SessionPrincipalKind.profileUnavailable);
  });
}
