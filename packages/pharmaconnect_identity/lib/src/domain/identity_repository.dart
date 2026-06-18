import 'profile.dart';

abstract interface class IdentityRepository {
  Future<Profile?> getCurrentProfile();

  Future<Profile> updateMyProfile({
    required String? fullName,
    required String? phone,
    required String? countryId,
    required String? cityId,
  });
}
