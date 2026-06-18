import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/identity_repository.dart';
import '../domain/profile.dart';
import 'profile_dto.dart';

class SupabaseIdentityRepository implements IdentityRepository {
  const SupabaseIdentityRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Profile?> getCurrentProfile() async {
    final User? user = _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    final Map<String, dynamic>? response = await _client
        .from('profiles')
        .select()
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return ProfileDto.fromJson(response.cast<String, Object?>()).toDomain();
  }

  @override
  Future<Profile> updateMyProfile({
    required String? fullName,
    required String? phone,
    required String? countryId,
    required String? cityId,
  }) async {
    final Object? response = await _client.rpc<Object?>(
      'update_my_profile',
      params: <String, Object?>{
        'full_name': fullName,
        'phone': phone,
        'country_id': countryId,
        'city_id': cityId,
      },
    );

    return ProfileDto.fromJson(_asJsonObject(response)).toDomain();
  }

  Map<String, Object?> _asJsonObject(Object? response) {
    if (response is Map<String, dynamic>) {
      return response.cast<String, Object?>();
    }

    if (response is List<dynamic> &&
        response.length == 1 &&
        response.single is Map<String, dynamic>) {
      return (response.single as Map<String, dynamic>)
          .cast<String, Object?>();
    }

    throw const FormatException(
      'The profile response was not a JSON object.',
    );
  }
}
