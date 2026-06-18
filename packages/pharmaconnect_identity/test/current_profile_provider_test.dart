import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

void main() {
  test('current profile is null when no auth user exists', () async {
    final _FakeIdentityRepository repository = _FakeIdentityRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        authUserProvider.overrideWithValue(
          const AsyncData(null),
        ),
        identityRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(currentProfileProvider.future), isNull);
    expect(repository.getCurrentProfileCalled, isFalse);
  });
}

class _FakeIdentityRepository implements IdentityRepository {
  bool getCurrentProfileCalled = false;

  @override
  Future<Profile?> getCurrentProfile() async {
    getCurrentProfileCalled = true;
    return null;
  }

  @override
  Future<Profile> updateMyProfile({
    required String? fullName,
    required String? phone,
    required String? countryId,
    required String? cityId,
  }) {
    throw UnimplementedError();
  }
}
