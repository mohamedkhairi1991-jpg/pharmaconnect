import '../domain/platform_role.dart';
import '../domain/profile.dart';
import '../domain/profile_status.dart';

class ProfileDto {
  const ProfileDto({
    required this.id,
    required this.authUserId,
    required this.email,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    this.phone,
    this.role,
    this.countryId,
    this.cityId,
  });

  factory ProfileDto.fromJson(Map<String, Object?> json) {
    final Object? roleValue = json['role'];

    return ProfileDto(
      id: json['id']! as String,
      authUserId: json['auth_user_id']! as String,
      fullName: json['full_name'] as String?,
      email: json['email']! as String,
      phone: json['phone'] as String?,
      role: roleValue == null
          ? null
          : PlatformRole.fromDatabaseValue(roleValue as String),
      countryId: json['country_id'] as String?,
      cityId: json['city_id'] as String?,
      status: ProfileStatus.fromDatabaseValue(json['status']! as String),
      createdAt: DateTime.parse(json['created_at']! as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at']! as String).toUtc(),
    );
  }

  final String id;
  final String authUserId;
  final String? fullName;
  final String email;
  final String? phone;
  final PlatformRole? role;
  final String? countryId;
  final String? cityId;
  final ProfileStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile toDomain() {
    return Profile(
      id: id,
      authUserId: authUserId,
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
      countryId: countryId,
      cityId: cityId,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
