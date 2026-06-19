import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

import '../../domain/access/catalog_company_access.dart';
import '../../domain/access/healthcare_professional_eligibility_summary.dart';
import '../../domain/catalog_enums.dart';
import '../parsing/json_reader.dart';

final class HealthcareProfessionalEligibilityDto {
  const HealthcareProfessionalEligibilityDto({
    required this.professionalId,
    required this.profileId,
    required this.professionType,
    required this.verificationStatus,
    required this.profileStatus,
    this.specialtyId,
  });

  factory HealthcareProfessionalEligibilityDto.fromJson(
    Map<String, Object?> json,
  ) {
    final JsonReader reader = JsonReader(
      json,
      context: 'healthcare_professional_eligibility',
    );
    final Map<String, Object?> profile = reader.object('profiles');
    final JsonReader profileReader = JsonReader(profile, context: 'profile');
    return HealthcareProfessionalEligibilityDto(
      professionalId: reader.string('id'),
      profileId: reader.string('profile_id'),
      professionType: ProfessionType.fromDatabaseValue(
        reader.string('profession_type'),
      ),
      verificationStatus:
          HealthcareProfessionalVerificationStatus.fromDatabaseValue(
            reader.string('verification_status'),
          ),
      specialtyId: reader.nullableString('specialty_id'),
      profileStatus: ProfileStatus.fromDatabaseValue(
        profileReader.string('status'),
      ),
    );
  }

  final String professionalId;
  final String profileId;
  final ProfessionType professionType;
  final HealthcareProfessionalVerificationStatus verificationStatus;
  final String? specialtyId;
  final ProfileStatus profileStatus;

  HealthcareProfessionalEligibilitySummary toDomain() {
    return HealthcareProfessionalEligibilitySummary(
      professionalId: professionalId,
      profileId: profileId,
      professionType: professionType,
      verificationStatus: verificationStatus,
      profileStatus: profileStatus,
      specialtyId: specialtyId,
    );
  }
}

final class CatalogCompanyAccessDto {
  const CatalogCompanyAccessDto({
    required this.companyId,
    required this.companyName,
    required this.companyStatus,
    required this.membershipId,
    required this.companyRole,
    required this.isMembershipActive,
    required this.profileStatus,
  });

  factory CatalogCompanyAccessDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(
      json,
      context: 'catalog_company_access',
    );
    final JsonReader company = JsonReader(
      reader.object('companies'),
      context: 'company',
    );
    final JsonReader profile = JsonReader(
      reader.object('profiles'),
      context: 'profile',
    );
    return CatalogCompanyAccessDto(
      companyId: reader.string('company_id'),
      companyName: company.string('company_name'),
      companyStatus: CompanyStatus.fromDatabaseValue(company.string('status')),
      membershipId: reader.string('id'),
      companyRole: CompanyRole.fromDatabaseValue(reader.string('company_role')),
      isMembershipActive: reader.boolean('is_active'),
      profileStatus: ProfileStatus.fromDatabaseValue(profile.string('status')),
    );
  }

  final String companyId;
  final String companyName;
  final CompanyStatus companyStatus;
  final String membershipId;
  final CompanyRole companyRole;
  final bool isMembershipActive;
  final ProfileStatus profileStatus;

  CatalogCompanyAccess toDomain() {
    return CatalogCompanyAccess(
      companyId: companyId,
      companyName: companyName,
      companyStatus: companyStatus,
      membershipId: membershipId,
      companyRole: companyRole,
      isMembershipActive: isMembershipActive,
      profileStatus: profileStatus,
    );
  }
}
