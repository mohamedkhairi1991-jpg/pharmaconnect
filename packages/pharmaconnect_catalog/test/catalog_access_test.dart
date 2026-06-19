import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

void main() {
  test('only active approved physicians are official catalog eligible', () {
    const HealthcareProfessionalEligibilitySummary physician =
        HealthcareProfessionalEligibilitySummary(
          professionalId: 'professional',
          profileId: 'profile',
          professionType: ProfessionType.physician,
          verificationStatus: HealthcareProfessionalVerificationStatus.approved,
          profileStatus: ProfileStatus.active,
        );
    const HealthcareProfessionalEligibilitySummary pharmacist =
        HealthcareProfessionalEligibilitySummary(
          professionalId: 'pharmacist',
          profileId: 'profile-2',
          professionType: ProfessionType.pharmacist,
          verificationStatus: HealthcareProfessionalVerificationStatus.approved,
          profileStatus: ProfileStatus.active,
        );
    const HealthcareProfessionalEligibilitySummary pendingPhysician =
        HealthcareProfessionalEligibilitySummary(
          professionalId: 'pending',
          profileId: 'profile-3',
          professionType: ProfessionType.physician,
          verificationStatus: HealthcareProfessionalVerificationStatus.pending,
          profileStatus: ProfileStatus.active,
        );

    expect(physician.isOfficialCatalogEligible, isTrue);
    expect(pharmacist.isOfficialCatalogEligible, isFalse);
    expect(pendingPhysician.isOfficialCatalogEligible, isFalse);
  });

  test('company admin and product manager receive mutation capabilities', () {
    final CatalogCompanyAccess admin = _access(CompanyRole.companyAdmin);
    final CatalogCompanyAccess productManager = _access(
      CompanyRole.productManager,
    );

    expect(admin.canReadWorkflow, isTrue);
    expect(admin.canManageDrafts, isTrue);
    expect(productManager.canSubmit, isTrue);
    expect(productManager.canArchiveOwnEligibleProducts, isTrue);
  });

  test('marketing manager is read-only and viewer fails closed', () {
    final CatalogCompanyAccess marketing = _access(
      CompanyRole.marketingManager,
    );
    final CatalogCompanyAccess viewer = _access(CompanyRole.viewer);

    expect(marketing.canReadWorkflow, isTrue);
    expect(marketing.canManageDrafts, isFalse);
    expect(viewer.canReadWorkflow, isFalse);
    expect(viewer.canSubmit, isFalse);
  });

  test('suspended company and profile lose all catalog capabilities', () {
    final CatalogCompanyAccess suspendedCompany = _access(
      CompanyRole.companyAdmin,
      companyStatus: CompanyStatus.suspended,
    );
    final CatalogCompanyAccess suspendedProfile = _access(
      CompanyRole.companyAdmin,
      profileStatus: ProfileStatus.suspended,
    );

    expect(suspendedCompany.canReadWorkflow, isFalse);
    expect(suspendedCompany.canManageDrafts, isFalse);
    expect(suspendedProfile.canReadWorkflow, isFalse);
    expect(suspendedProfile.canManageDrafts, isFalse);
  });
}

CatalogCompanyAccess _access(
  CompanyRole role, {
  CompanyStatus companyStatus = CompanyStatus.verified,
  ProfileStatus profileStatus = ProfileStatus.active,
}) {
  return CatalogCompanyAccess(
    companyId: 'company',
    companyName: 'Company',
    companyStatus: companyStatus,
    membershipId: 'membership',
    companyRole: role,
    isMembershipActive: true,
    profileStatus: profileStatus,
  );
}
