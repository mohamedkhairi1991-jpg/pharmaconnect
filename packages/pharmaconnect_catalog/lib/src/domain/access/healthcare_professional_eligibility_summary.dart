import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

import '../catalog_enums.dart';

final class HealthcareProfessionalEligibilitySummary {
  const HealthcareProfessionalEligibilitySummary({
    required this.professionalId,
    required this.profileId,
    required this.professionType,
    required this.verificationStatus,
    required this.profileStatus,
    this.specialtyId,
  });

  final String professionalId;
  final String profileId;
  final ProfessionType professionType;
  final HealthcareProfessionalVerificationStatus verificationStatus;
  final String? specialtyId;
  final ProfileStatus profileStatus;

  bool get isOfficialCatalogEligible =>
      profileStatus == ProfileStatus.active &&
      professionType == ProfessionType.physician &&
      verificationStatus == HealthcareProfessionalVerificationStatus.approved;
}
