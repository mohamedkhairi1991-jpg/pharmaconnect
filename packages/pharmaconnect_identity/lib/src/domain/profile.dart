import 'platform_role.dart';
import 'profile_status.dart';

class Profile {
  const Profile({
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
}
