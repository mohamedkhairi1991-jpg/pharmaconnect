import 'dart:typed_data';

import '../catalog_enums.dart';

final class CatalogUploadFile {
  const CatalogUploadFile({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final Uint8List bytes;
}

final class ProductListRequest {
  const ProductListRequest({
    this.limit = 50,
    this.offset = 0,
    this.preferredLocale = ContentLocale.english,
  });

  final int limit;
  final int offset;
  final ContentLocale preferredLocale;
}

final class CreateProductDraftCommand {
  const CreateProductDraftCommand({
    required this.companyId,
    required this.category,
    required this.drugClassId,
    required this.englishBrandName,
    this.genericDrugId,
  });

  final String companyId;
  final ProductCategory category;
  final String? genericDrugId;
  final String drugClassId;
  final String englishBrandName;
}

final class UpdateProductDraftCommand {
  const UpdateProductDraftCommand({
    required this.productId,
    required this.category,
    required this.drugClassId,
    this.genericDrugId,
  });

  final String productId;
  final ProductCategory category;
  final String? genericDrugId;
  final String drugClassId;
}

final class ProductMarketCommand {
  const ProductMarketCommand({
    required this.productId,
    required this.strength,
    required this.dosageForm,
    required this.route,
    required this.packSize,
    required this.marketStatus,
    required this.registrationStatus,
    this.registrationNumber,
    this.registrationAuthority,
    this.registrationExpiresOn,
  });

  final String productId;
  final String strength;
  final String dosageForm;
  final String route;
  final String packSize;
  final IraqMarketStatus marketStatus;
  final ProductRegistrationStatus registrationStatus;
  final String? registrationNumber;
  final String? registrationAuthority;
  final DateTime? registrationExpiresOn;
}

final class ProductMarketTranslationCommand {
  const ProductMarketTranslationCommand({
    required this.productId,
    required this.locale,
    required this.storageConditions,
    required this.approvedIndications,
    required this.usualAdultDose,
    required this.contraindications,
    required this.commonAdverseEffects,
  });

  final String productId;
  final ContentLocale locale;
  final String storageConditions;
  final String approvedIndications;
  final String usualAdultDose;
  final String contraindications;
  final String commonAdverseEffects;
}

final class ProductMediaMetadataCommand {
  const ProductMediaMetadataCommand({
    required this.productId,
    required this.type,
    required this.storagePath,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.sortOrder,
    required this.isPrimary,
    this.mediaId,
  });

  final String? mediaId;
  final String productId;
  final ProductMediaType type;
  final String storagePath;
  final String mimeType;
  final int fileSizeBytes;
  final int sortOrder;
  final bool isPrimary;
}

final class ProductBrochureMetadataCommand {
  const ProductBrochureMetadataCommand({
    required this.productId,
    required this.locale,
    required this.title,
    required this.storagePath,
    required this.fileSizeBytes,
    required this.version,
    required this.isCurrent,
    this.brochureId,
  });

  final String? brochureId;
  final String productId;
  final ContentLocale locale;
  final String title;
  final String storagePath;
  final int fileSizeBytes;
  final int version;
  final bool isCurrent;
}
