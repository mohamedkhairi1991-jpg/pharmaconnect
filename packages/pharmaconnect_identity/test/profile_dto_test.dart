import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

void main() {
  test('profile DTO supports an unclassified pending profile', () {
    final Profile profile = ProfileDto.fromJson(<String, Object?>{
      'id': '00000000-0000-4000-8000-000000000001',
      'auth_user_id': '00000000-0000-4000-8000-000000000002',
      'full_name': null,
      'email': 'user@example.com',
      'phone': null,
      'role': null,
      'country_id': null,
      'city_id': null,
      'status': 'pending',
      'created_at': '2026-06-18T00:00:00Z',
      'updated_at': '2026-06-18T00:00:00Z',
    }).toDomain();

    expect(profile.role, isNull);
    expect(profile.status, ProfileStatus.pending);
    expect(profile.createdAt.isUtc, isTrue);
  });
}
