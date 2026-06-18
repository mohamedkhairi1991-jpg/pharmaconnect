import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';

void main() {
  test('auth user provider can be overridden for consumers', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [authUserProvider.overrideWithValue(const AsyncData(null))],
    );
    addTearDown(container.dispose);

    expect(await container.read(authUserProvider.future), isNull);
  });
}
