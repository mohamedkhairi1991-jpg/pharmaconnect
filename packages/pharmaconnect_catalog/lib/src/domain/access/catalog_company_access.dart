import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

import '../catalog_enums.dart';

final class CatalogCompanyAccess {
  const CatalogCompanyAccess({
    required this.companyId,
    required this.companyName,
    required this.companyStatus,
    required this.membershipId,
    required this.companyRole,
    required this.isMembershipActive,
    required this.profileStatus,
  });

  final String companyId;
  final String companyName;
  final CompanyStatus companyStatus;
  final String membershipId;
  final CompanyRole companyRole;
  final bool isMembershipActive;
  final ProfileStatus profileStatus;

  bool get _hasActiveVerifiedContext =>
      profileStatus == ProfileStatus.active &&
      companyStatus == CompanyStatus.verified &&
      isMembershipActive;

  bool get canReadWorkflow =>
      _hasActiveVerifiedContext &&
      switch (companyRole) {
        CompanyRole.companyAdmin ||
        CompanyRole.marketingManager ||
        CompanyRole.productManager => true,
        CompanyRole.representative || CompanyRole.viewer => false,
      };

  bool get canManageDrafts =>
      _hasActiveVerifiedContext &&
      (companyRole == CompanyRole.companyAdmin ||
          companyRole == CompanyRole.productManager);

  bool get canSubmit => canManageDrafts;

  bool get canArchiveOwnEligibleProducts => canManageDrafts;
}
