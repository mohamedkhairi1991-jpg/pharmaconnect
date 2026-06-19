import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';

void main() {
  test('catalog enums parse and serialize database values', () {
    expect(
      ProductCategory.fromDatabaseValue('prescription_drug'),
      ProductCategory.prescriptionDrug,
    );
    expect(ProductCategory.otcDrug.databaseValue, 'otc_drug');
    expect(
      ProductLifecycleStatus.fromDatabaseValue('changes_requested'),
      ProductLifecycleStatus.changesRequested,
    );
    expect(ProductLifecycleStatus.published.databaseValue, 'published');
    expect(
      IraqMarketStatus.fromDatabaseValue('marketed_in_iraq'),
      IraqMarketStatus.marketedInIraq,
    );
    expect(
      ProductRegistrationStatus.fromDatabaseValue('not_recorded'),
      ProductRegistrationStatus.notRecorded,
    );
    expect(
      ProductMediaType.fromDatabaseValue('package_image'),
      ProductMediaType.packageImage,
    );
    expect(ContentLocale.fromDatabaseValue('ar'), ContentLocale.arabic);
    expect(
      CatalogReadinessStage.fromDatabaseValue('publication'),
      CatalogReadinessStage.publication,
    );
    expect(
      CatalogReadinessIssue.fromDatabaseValue('duplicate_presentation'),
      CatalogReadinessIssue.duplicatePresentation,
    );
  });

  test('access prerequisite enums parse database values', () {
    expect(
      ProfessionType.fromDatabaseValue('physician'),
      ProfessionType.physician,
    );
    expect(
      HealthcareProfessionalVerificationStatus.fromDatabaseValue('approved'),
      HealthcareProfessionalVerificationStatus.approved,
    );
    expect(CompanyStatus.fromDatabaseValue('verified'), CompanyStatus.verified);
    expect(
      CompanyRole.fromDatabaseValue('product_manager'),
      CompanyRole.productManager,
    );
  });

  test('unknown persisted enum values fail as incompatible data', () {
    expect(
      () => ProductLifecycleStatus.fromDatabaseValue('future_state'),
      throwsA(
        isA<CatalogFailure>().having(
          (CatalogFailure failure) => failure.kind,
          'kind',
          CatalogFailureKind.incompatibleData,
        ),
      ),
    );
  });

  test('lifecycle status exposes company edit and doctor visibility rules', () {
    expect(ProductLifecycleStatus.draft.isCompanyEditable, isTrue);
    expect(ProductLifecycleStatus.changesRequested.isCompanyEditable, isTrue);
    expect(ProductLifecycleStatus.submitted.isCompanyEditable, isFalse);
    expect(ProductLifecycleStatus.published.isDoctorVisible, isTrue);
    expect(ProductLifecycleStatus.hidden.isDoctorVisible, isFalse);
  });
}
