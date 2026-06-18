import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

void main() {
  test('platform roles map to database values', () {
    expect(
      PlatformRole.fromDatabaseValue('healthcare_professional'),
      PlatformRole.healthcareProfessional,
    );
    expect(PlatformRole.superAdmin.databaseValue, 'super_admin');
  });

  test('unknown platform roles fail safely', () {
    expect(
      () => PlatformRole.fromDatabaseValue('unknown'),
      throwsFormatException,
    );
  });
}
