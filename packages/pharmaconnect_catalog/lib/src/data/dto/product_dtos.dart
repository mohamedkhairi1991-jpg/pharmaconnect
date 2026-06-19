import '../../domain/catalog_enums.dart';
import '../../domain/company/catalog_company_summary.dart';
import '../../domain/localization/localized_content.dart';
import '../../domain/product/product_brochure_metadata.dart';
import '../../domain/product/product_lifecycle_metadata.dart';
import '../../domain/product/product_market.dart';
import '../../domain/product/product_market_translation.dart';
import '../../domain/product/product_media_metadata.dart';
import '../../domain/product/product_translation.dart';
import '../parsing/json_reader.dart';
import 'taxonomy_dtos.dart';

final class CatalogCompanySummaryDto {
  const CatalogCompanySummaryDto({
    required this.id,
    required this.companyName,
    required this.legalName,
    required this.countryId,
    required this.status,
    this.cityId,
  });

  factory CatalogCompanySummaryDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json, context: 'catalog_company');
    return CatalogCompanySummaryDto(
      id: reader.string('id'),
      companyName: reader.string('company_name'),
      legalName: reader.string('legal_name'),
      countryId: reader.string('country_id'),
      cityId: reader.nullableString('city_id'),
      status: CompanyStatus.fromDatabaseValue(reader.string('status')),
    );
  }

  final String id;
  final String companyName;
  final String legalName;
  final String countryId;
  final String? cityId;
  final CompanyStatus status;

  CatalogCompanySummary toDomain() => CatalogCompanySummary(
    id: id,
    companyName: companyName,
    legalName: legalName,
    countryId: countryId,
    cityId: cityId,
    status: status,
  );
}

final class ProductTranslationDto {
  const ProductTranslationDto({
    required this.id,
    required this.locale,
    required this.brandName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductTranslationDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json, context: 'product_translation');
    return ProductTranslationDto(
      id: reader.string('id'),
      locale: ContentLocale.fromDatabaseValue(reader.string('locale')),
      brandName: reader.string('brand_name'),
      createdAt: reader.dateTime('created_at'),
      updatedAt: reader.dateTime('updated_at'),
    );
  }

  final String id;
  final ContentLocale locale;
  final String brandName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductTranslation toDomain() => ProductTranslation(
    id: id,
    locale: locale,
    brandName: brandName,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

final class ProductMarketTranslationDto {
  const ProductMarketTranslationDto({
    required this.id,
    required this.locale,
    required this.storageConditions,
    required this.approvedIndications,
    required this.usualAdultDose,
    required this.contraindications,
    required this.commonAdverseEffects,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductMarketTranslationDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(
      json,
      context: 'product_market_translation',
    );
    return ProductMarketTranslationDto(
      id: reader.string('id'),
      locale: ContentLocale.fromDatabaseValue(reader.string('locale')),
      storageConditions: reader.string('storage_conditions'),
      approvedIndications: reader.string('approved_indications'),
      usualAdultDose: reader.string('usual_adult_dose'),
      contraindications: reader.string('contraindications'),
      commonAdverseEffects: reader.string('common_adverse_effects'),
      createdAt: reader.dateTime('created_at'),
      updatedAt: reader.dateTime('updated_at'),
    );
  }

  final String id;
  final ContentLocale locale;
  final String storageConditions;
  final String approvedIndications;
  final String usualAdultDose;
  final String contraindications;
  final String commonAdverseEffects;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductMarketTranslation toDomain() => ProductMarketTranslation(
    id: id,
    locale: locale,
    storageConditions: storageConditions,
    approvedIndications: approvedIndications,
    usualAdultDose: usualAdultDose,
    contraindications: contraindications,
    commonAdverseEffects: commonAdverseEffects,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

final class ProductMarketDto {
  ProductMarketDto({
    required this.id,
    required this.countryId,
    required this.strength,
    required this.dosageForm,
    required this.route,
    required this.packSize,
    required this.marketStatus,
    required this.registrationStatus,
    required Iterable<ProductMarketTranslationDto> translations,
    required Iterable<ProductBrochureMetadataDto> brochures,
    required this.createdAt,
    required this.updatedAt,
    this.registrationNumber,
    this.registrationAuthority,
    this.registrationExpiresOn,
  }) : translations = List<ProductMarketTranslationDto>.unmodifiable(
         translations,
       ),
       brochures = List<ProductBrochureMetadataDto>.unmodifiable(brochures);

  factory ProductMarketDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json, context: 'product_market');
    return ProductMarketDto(
      id: reader.string('id'),
      countryId: reader.string('country_id'),
      strength: reader.string('strength'),
      dosageForm: reader.string('dosage_form'),
      route: reader.string('route'),
      packSize: reader.string('pack_size'),
      marketStatus: IraqMarketStatus.fromDatabaseValue(
        reader.string('market_status'),
      ),
      registrationStatus: ProductRegistrationStatus.fromDatabaseValue(
        reader.string('registration_status'),
      ),
      registrationNumber: reader.nullableString('registration_number'),
      registrationAuthority: reader.nullableString('registration_authority'),
      registrationExpiresOn: reader.nullableDateTime('registration_expires_on'),
      translations: reader
          .objects('product_market_translations')
          .map(ProductMarketTranslationDto.fromJson),
      brochures: reader
          .objects('product_brochures')
          .map(ProductBrochureMetadataDto.fromJson),
      createdAt: reader.dateTime('created_at'),
      updatedAt: reader.dateTime('updated_at'),
    );
  }

  final String id;
  final String countryId;
  final String strength;
  final String dosageForm;
  final String route;
  final String packSize;
  final IraqMarketStatus marketStatus;
  final ProductRegistrationStatus registrationStatus;
  final String? registrationNumber;
  final String? registrationAuthority;
  final DateTime? registrationExpiresOn;
  final List<ProductMarketTranslationDto> translations;
  final List<ProductBrochureMetadataDto> brochures;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductMarket toDomain() {
    ProductMarketTranslation? english;
    ProductMarketTranslation? arabic;
    for (final ProductMarketTranslationDto value in translations) {
      final ProductMarketTranslation domain = value.toDomain();
      if (domain.locale == ContentLocale.english) {
        english = domain;
      } else {
        arabic = domain;
      }
    }
    return ProductMarket(
      id: id,
      countryId: countryId,
      strength: strength,
      dosageForm: dosageForm,
      route: route,
      packSize: packSize,
      marketStatus: marketStatus,
      registrationStatus: registrationStatus,
      registrationNumber: registrationNumber,
      registrationAuthority: registrationAuthority,
      registrationExpiresOn: registrationExpiresOn,
      translations: LocalizedContent<ProductMarketTranslation>(
        english: english,
        arabic: arabic,
      ),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

final class ProductMediaMetadataDto {
  const ProductMediaMetadataDto({
    required this.id,
    required this.type,
    required this.storagePath,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.sortOrder,
    required this.isPrimary,
    required this.uploadedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductMediaMetadataDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json, context: 'product_media');
    return ProductMediaMetadataDto(
      id: reader.string('id'),
      type: ProductMediaType.fromDatabaseValue(reader.string('media_type')),
      storagePath: reader.string('storage_path'),
      mimeType: reader.string('mime_type'),
      fileSizeBytes: reader.integer('file_size_bytes'),
      sortOrder: reader.integer('sort_order'),
      isPrimary: reader.boolean('is_primary'),
      uploadedBy: reader.string('uploaded_by'),
      createdAt: reader.dateTime('created_at'),
      updatedAt: reader.dateTime('updated_at'),
    );
  }

  final String id;
  final ProductMediaType type;
  final String storagePath;
  final String mimeType;
  final int fileSizeBytes;
  final int sortOrder;
  final bool isPrimary;
  final String uploadedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductMediaMetadata toDomain() => ProductMediaMetadata(
    id: id,
    type: type,
    storagePath: storagePath,
    mimeType: mimeType,
    fileSizeBytes: fileSizeBytes,
    sortOrder: sortOrder,
    isPrimary: isPrimary,
    uploadedBy: uploadedBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

final class ProductBrochureMetadataDto {
  const ProductBrochureMetadataDto({
    required this.id,
    required this.productMarketId,
    required this.locale,
    required this.title,
    required this.storagePath,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.version,
    required this.isCurrent,
    required this.uploadedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductBrochureMetadataDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json, context: 'product_brochure');
    return ProductBrochureMetadataDto(
      id: reader.string('id'),
      productMarketId: reader.string('product_market_id'),
      locale: ContentLocale.fromDatabaseValue(reader.string('locale')),
      title: reader.string('title'),
      storagePath: reader.string('storage_path'),
      mimeType: reader.string('mime_type'),
      fileSizeBytes: reader.integer('file_size_bytes'),
      version: reader.integer('version'),
      isCurrent: reader.boolean('is_current'),
      uploadedBy: reader.string('uploaded_by'),
      createdAt: reader.dateTime('created_at'),
      updatedAt: reader.dateTime('updated_at'),
    );
  }

  final String id;
  final String productMarketId;
  final ContentLocale locale;
  final String title;
  final String storagePath;
  final String mimeType;
  final int fileSizeBytes;
  final int version;
  final bool isCurrent;
  final String uploadedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductBrochureMetadata toDomain() => ProductBrochureMetadata(
    id: id,
    productMarketId: productMarketId,
    locale: locale,
    title: title,
    storagePath: storagePath,
    mimeType: mimeType,
    fileSizeBytes: fileSizeBytes,
    version: version,
    isCurrent: isCurrent,
    uploadedBy: uploadedBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

final class ProductDto {
  ProductDto({
    required this.id,
    required this.company,
    required this.drugClass,
    required this.category,
    required this.status,
    required this.translations,
    required this.markets,
    required this.specialties,
    required this.media,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.genericDrug,
    this.presentationFingerprint,
  });

  factory ProductDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json, context: 'product');
    final Map<String, Object?>? generic = reader.nullableObject(
      'generic_drugs',
    );
    return ProductDto(
      id: reader.string('id'),
      company: CatalogCompanySummaryDto.fromJson(reader.object('companies')),
      genericDrug: generic == null ? null : GenericDrugDto.fromJson(generic),
      drugClass: DrugClassDto.fromJson(reader.object('drug_classes')),
      category: ProductCategory.fromDatabaseValue(reader.string('category')),
      status: ProductLifecycleStatus.fromDatabaseValue(reader.string('status')),
      presentationFingerprint: reader.nullableString(
        'presentation_fingerprint',
      ),
      translations: reader
          .objects('product_translations')
          .map(ProductTranslationDto.fromJson)
          .toList(growable: false),
      markets: reader
          .objects('product_markets')
          .map(ProductMarketDto.fromJson)
          .toList(growable: false),
      specialties: reader
          .objects('product_specialties')
          .map(ProductSpecialtyDto.fromJson)
          .toList(growable: false),
      media: reader
          .objects('product_media')
          .map(ProductMediaMetadataDto.fromJson)
          .toList(growable: false),
      lifecycle: ProductLifecycleMetadata(
        submittedBy: reader.nullableString('submitted_by'),
        submittedAt: reader.nullableDateTime('submitted_at'),
        reviewedBy: reader.nullableString('reviewed_by'),
        reviewedAt: reader.nullableDateTime('reviewed_at'),
        reviewReason: reader.nullableString('review_reason'),
        publishedBy: reader.nullableString('published_by'),
        publishedAt: reader.nullableDateTime('published_at'),
        hiddenBy: reader.nullableString('hidden_by'),
        hiddenAt: reader.nullableDateTime('hidden_at'),
        hiddenReason: reader.nullableString('hidden_reason'),
        archivedBy: reader.nullableString('archived_by'),
        archivedAt: reader.nullableDateTime('archived_at'),
        archiveReason: reader.nullableString('archive_reason'),
      ),
      createdAt: reader.dateTime('created_at'),
      updatedAt: reader.dateTime('updated_at'),
    );
  }

  final String id;
  final CatalogCompanySummaryDto company;
  final GenericDrugDto? genericDrug;
  final DrugClassDto drugClass;
  final ProductCategory category;
  final ProductLifecycleStatus status;
  final String? presentationFingerprint;
  final List<ProductTranslationDto> translations;
  final List<ProductMarketDto> markets;
  final List<ProductSpecialtyDto> specialties;
  final List<ProductMediaMetadataDto> media;
  List<ProductBrochureMetadataDto> get brochures => List.unmodifiable(
    markets.expand((ProductMarketDto market) => market.brochures),
  );
  final ProductLifecycleMetadata lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
}
