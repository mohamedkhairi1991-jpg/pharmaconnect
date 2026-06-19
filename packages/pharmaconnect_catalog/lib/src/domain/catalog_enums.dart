import 'failure/catalog_failure.dart';

enum ProductCategory {
  prescriptionDrug('prescription_drug'),
  otcDrug('otc_drug'),
  dietarySupplement('dietary_supplement');

  const ProductCategory(this.databaseValue);

  final String databaseValue;

  static ProductCategory fromDatabaseValue(String value) =>
      _parseEnum(values, value, 'product_category');
}

enum ProductLifecycleStatus {
  draft('draft'),
  submitted('submitted'),
  changesRequested('changes_requested'),
  published('published'),
  hidden('hidden'),
  archived('archived');

  const ProductLifecycleStatus(this.databaseValue);

  final String databaseValue;

  bool get isCompanyEditable =>
      this == ProductLifecycleStatus.draft ||
      this == ProductLifecycleStatus.changesRequested;

  bool get isDoctorVisible => this == ProductLifecycleStatus.published;

  static ProductLifecycleStatus fromDatabaseValue(String value) =>
      _parseEnum(values, value, 'product_status');
}

enum IraqMarketStatus {
  marketedInIraq('marketed_in_iraq'),
  notMarketed('not_marketed'),
  discontinued('discontinued');

  const IraqMarketStatus(this.databaseValue);

  final String databaseValue;

  static IraqMarketStatus fromDatabaseValue(String value) =>
      _parseEnum(values, value, 'iraq_market_status');
}

enum ProductRegistrationStatus {
  notRecorded('not_recorded'),
  registered('registered'),
  expired('expired'),
  withdrawn('withdrawn');

  const ProductRegistrationStatus(this.databaseValue);

  final String databaseValue;

  static ProductRegistrationStatus fromDatabaseValue(String value) =>
      _parseEnum(values, value, 'product_registration_status');
}

enum ProductMediaType {
  productImage('product_image'),
  packageImage('package_image');

  const ProductMediaType(this.databaseValue);

  final String databaseValue;

  static ProductMediaType fromDatabaseValue(String value) =>
      _parseEnum(values, value, 'product_media_type');
}

enum ContentLocale {
  english('en'),
  arabic('ar');

  const ContentLocale(this.databaseValue);

  final String databaseValue;

  static ContentLocale fromDatabaseValue(String value) =>
      _parseEnum(values, value, 'content_locale');
}

enum CatalogReadinessStage {
  submission('submission'),
  publication('publication');

  const CatalogReadinessStage(this.databaseValue);

  final String databaseValue;

  static CatalogReadinessStage fromDatabaseValue(String value) =>
      _parseEnum(values, value, 'catalog_readiness_stage');
}

enum CatalogReadinessIssue {
  productNotFound('product_not_found'),
  companyNotVerified('company_not_verified'),
  drugClassNotActive('drug_class_not_active'),
  genericDrugNotActive('generic_drug_not_active'),
  genericCompositionInvalid('generic_composition_invalid'),
  englishProductTranslationMissing('english_product_translation_missing'),
  iraqMarketMissing('iraq_market_missing'),
  englishIraqContentMissing('english_iraq_content_missing'),
  notMarketedInIraq('not_marketed_in_iraq'),
  activeSpecialtyMissing('active_specialty_missing'),
  presentationFingerprintMissing('presentation_fingerprint_missing'),
  duplicatePresentation('duplicate_presentation');

  const CatalogReadinessIssue(this.databaseValue);

  final String databaseValue;

  static CatalogReadinessIssue fromDatabaseValue(String value) =>
      _parseEnum(values, value, 'catalog_readiness_issue');
}

enum ProfessionType {
  physician('physician'),
  pharmacist('pharmacist');

  const ProfessionType(this.databaseValue);

  final String databaseValue;

  static ProfessionType fromDatabaseValue(String value) =>
      _parseEnum(values, value, 'profession_type');
}

enum HealthcareProfessionalVerificationStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  documentsRequested('documents_requested');

  const HealthcareProfessionalVerificationStatus(this.databaseValue);

  final String databaseValue;

  static HealthcareProfessionalVerificationStatus fromDatabaseValue(
    String value,
  ) => _parseEnum(values, value, 'healthcare_professional_verification_status');
}

enum CompanyStatus {
  pending('pending'),
  verified('verified'),
  suspended('suspended'),
  archived('archived');

  const CompanyStatus(this.databaseValue);

  final String databaseValue;

  static CompanyStatus fromDatabaseValue(String value) =>
      _parseEnum(values, value, 'company_status');
}

enum CompanyRole {
  companyAdmin('company_admin'),
  marketingManager('marketing_manager'),
  productManager('product_manager'),
  representative('representative'),
  viewer('viewer');

  const CompanyRole(this.databaseValue);

  final String databaseValue;

  static CompanyRole fromDatabaseValue(String value) =>
      _parseEnum(values, value, 'company_role');
}

T _parseEnum<T extends Enum>(
  List<T> values,
  String databaseValue,
  String typeName,
) {
  for (final T value in values) {
    final String? candidate = switch (value) {
      final ProductCategory value => value.databaseValue,
      final ProductLifecycleStatus value => value.databaseValue,
      final IraqMarketStatus value => value.databaseValue,
      final ProductRegistrationStatus value => value.databaseValue,
      final ProductMediaType value => value.databaseValue,
      final ContentLocale value => value.databaseValue,
      final CatalogReadinessStage value => value.databaseValue,
      final CatalogReadinessIssue value => value.databaseValue,
      final ProfessionType value => value.databaseValue,
      final HealthcareProfessionalVerificationStatus value =>
        value.databaseValue,
      final CompanyStatus value => value.databaseValue,
      final CompanyRole value => value.databaseValue,
      _ => null,
    };
    if (candidate == databaseValue) {
      return value;
    }
  }

  throw CatalogFailure.incompatibleData(
    diagnosticCode: 'unknown_$typeName:$databaseValue',
  );
}
