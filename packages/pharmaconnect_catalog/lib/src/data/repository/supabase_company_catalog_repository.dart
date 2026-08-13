import 'dart:math';

import '../../domain/catalog_enums.dart';
import '../../domain/failure/catalog_failure.dart';
import '../../domain/product/product_brochure_metadata.dart';
import '../../domain/product/product_detail.dart';
import '../../domain/product/product_summary.dart';
import '../../domain/readiness/catalog_readiness_evaluator.dart';
import '../../domain/readiness/catalog_readiness_result.dart';
import '../../domain/repository/catalog_commands.dart';
import '../../domain/repository/catalog_repositories.dart';
import '../error/supabase_catalog_failure_mapper.dart';
import '../parsing/response_parser.dart';
import '../query/catalog_query_projections.dart';
import '../source/catalog_data_source.dart';
import 'repository_support.dart';

final class SupabaseCompanyCatalogRepository
    implements CompanyCatalogRepository {
  SupabaseCompanyCatalogRepository(
    this._source, [
    CatalogStorageDataSource? storage,
  ]) : _storage = storage;

  final CatalogDataSource _source;
  final CatalogStorageDataSource? _storage;

  static const String _mediaBucket = 'catalog-product-media';
  static const String _brochureBucket = 'catalog-brochures';
  static const int _maxMediaBytes = 10 * 1024 * 1024;
  static const int _maxBrochureBytes = 25 * 1024 * 1024;

  @override
  Future<ProductDetail> archiveOwnProduct(String productId, String reason) {
    return _mutate(CatalogRpcNames.archiveOwnProduct, <String, Object?>{
      'p_product_id': productId,
      'p_reason': reason,
    }, productId);
  }

  @override
  Future<ProductDetail> createDraft(CreateProductDraftCommand command) {
    return guardCatalogCall(() async {
      final Object? response = await _source
          .callRpc(CatalogRpcNames.createProductDraft, <String, Object?>{
            'p_company_id': command.companyId,
            'p_category': command.category.databaseValue,
            'p_generic_drug_id': command.genericDrugId,
            'p_drug_class_id': command.drugClassId,
            'p_english_brand_name': command.englishBrandName,
          });
      final Map<String, Object?> row = parseRpcObject(
        response,
        'create_product_draft',
      );
      final Object? id = row['id'];
      if (id is! String) {
        throw const CatalogFailure.incompatibleData(
          diagnosticCode: 'create_product_draft_missing_id',
        );
      }
      return readProductDetail(_source, id);
    });
  }

  @override
  Future<ProductDetail> getOwnProductDetail(String productId) {
    return readProductDetail(_source, productId);
  }

  @override
  Future<CatalogReadinessResult> getPublicationReadiness(String productId) {
    return _readiness(productId, CatalogReadinessStage.publication);
  }

  @override
  Future<CatalogReadinessResult> getSubmissionReadiness(String productId) {
    return _readiness(productId, CatalogReadinessStage.submission);
  }

  @override
  Future<List<ProductSummary>> listOwnProducts({
    ProductLifecycleStatus? status,
  }) {
    return guardCatalogCall(() async {
      final String companyId = await currentCompanyId(_source);
      final Map<String, Object> filters = <String, Object>{
        'company_id': companyId,
        'product_markets.country_id': CatalogReferenceIds.iraqCountryId,
        if (status != null) 'status': status.databaseValue,
      };
      return readProductSummaries(
        _source,
        CatalogReadRequest(
          table: CatalogTables.products,
          projection: CatalogQueryProjections.product,
          filters: filters,
          orderBy: 'updated_at',
          ascending: false,
        ),
      );
    });
  }

  @override
  Future<ProductDetail> setSpecialties(
    String productId,
    List<String> specialtyIds,
  ) {
    return _mutate(CatalogRpcNames.setProductSpecialties, <String, Object?>{
      'p_product_id': productId,
      'p_specialty_ids': specialtyIds,
    }, productId);
  }

  @override
  Future<ProductDetail> submitForReview(String productId) {
    return _mutate(CatalogRpcNames.submitProductForReview, <String, Object?>{
      'p_product_id': productId,
    }, productId);
  }

  @override
  Future<ProductDetail> updateDraft(UpdateProductDraftCommand command) {
    return _mutate(CatalogRpcNames.updateProductDraft, <String, Object?>{
      'p_product_id': command.productId,
      'p_category': command.category.databaseValue,
      'p_generic_drug_id': command.genericDrugId,
      'p_drug_class_id': command.drugClassId,
    }, command.productId);
  }

  @override
  Future<ProductDetail> upsertBrochureMetadata(
    ProductBrochureMetadataCommand command,
  ) {
    return _mutate(
      CatalogRpcNames.upsertProductBrochureMetadata,
      <String, Object?>{
        'p_brochure_id': command.brochureId,
        'p_product_id': command.productId,
        'p_locale': command.locale.databaseValue,
        'p_title': command.title,
        'p_storage_path': command.storagePath,
        'p_file_size_bytes': command.fileSizeBytes,
        'p_version': command.version,
        'p_is_current': command.isCurrent,
      },
      command.productId,
    );
  }

  @override
  Future<ProductDetail> uploadProductMedia({
    required String productId,
    required ProductMediaType type,
    required CatalogUploadFile file,
  }) => guardCatalogCall(() async {
    _validateUploadFile(
      file,
      allowedMimeTypes: const <String>{
        'image/jpeg',
        'image/png',
        'image/webp',
      },
      maxBytes: _maxMediaBytes,
    );
    final CatalogStorageDataSource storage = _requireStorage();
    final String path = _storagePath(productId, file.mimeType);
    await storage.uploadBinary(
      bucket: _mediaBucket,
      path: path,
      bytes: file.bytes,
      mimeType: file.mimeType,
    );
    try {
      return await upsertMediaMetadata(
        ProductMediaMetadataCommand(
          productId: productId,
          type: type,
          storagePath: path,
          mimeType: file.mimeType,
          fileSizeBytes: file.bytes.length,
          sortOrder: 0,
          isPrimary: true,
        ),
      );
    } on Object {
      await _removeFailedUpload(storage, _mediaBucket, path);
      rethrow;
    }
  });

  @override
  Future<ProductDetail> uploadBrochure({
    required String productId,
    required ContentLocale locale,
    required String title,
    required CatalogUploadFile file,
  }) => guardCatalogCall(() async {
    _validateUploadFile(
      file,
      allowedMimeTypes: const <String>{'application/pdf'},
      maxBytes: _maxBrochureBytes,
    );
    if (title.trim().isEmpty) {
      throw const CatalogFailure(
        kind: CatalogFailureKind.validation,
        diagnosticCode: 'brochure_title_missing',
      );
    }
    final ProductDetail current = await getOwnProductDetail(productId);
    final int nextVersion = current.brochures
            .where(
              (ProductBrochureMetadata brochure) => brochure.locale == locale,
            )
            .fold<int>(0, (int value, ProductBrochureMetadata brochure) {
              return max(value, brochure.version);
            }) +
        1;
    final CatalogStorageDataSource storage = _requireStorage();
    final String path = _storagePath(productId, file.mimeType);
    await storage.uploadBinary(
      bucket: _brochureBucket,
      path: path,
      bytes: file.bytes,
      mimeType: file.mimeType,
    );
    try {
      return await upsertBrochureMetadata(
        ProductBrochureMetadataCommand(
          productId: productId,
          locale: locale,
          title: title.trim(),
          storagePath: path,
          fileSizeBytes: file.bytes.length,
          version: nextVersion,
          isCurrent: true,
        ),
      );
    } on Object {
      await _removeFailedUpload(storage, _brochureBucket, path);
      rethrow;
    }
  });

  @override
  Future<ProductDetail> upsertIraqMarket(ProductMarketCommand command) {
    return _mutate(CatalogRpcNames.upsertProductMarket, <String, Object?>{
      'p_product_id': command.productId,
      'p_strength': command.strength,
      'p_dosage_form': command.dosageForm,
      'p_route': command.route,
      'p_pack_size': command.packSize,
      'p_market_status': command.marketStatus.databaseValue,
      'p_registration_status': command.registrationStatus.databaseValue,
      'p_registration_number': command.registrationNumber,
      'p_registration_authority': command.registrationAuthority,
      'p_registration_expires_on': command.registrationExpiresOn
          ?.toIso8601String()
          .split('T')
          .first,
    }, command.productId);
  }

  @override
  Future<ProductDetail> upsertKeywordAlias({
    required String productId,
    required String locale,
    required String keyword,
    required String keywordType,
  }) {
    return _mutate(CatalogRpcNames.upsertProductKeywordAlias, <String, Object?>{
      'p_product_id': productId,
      'p_locale': locale,
      'p_keyword': keyword,
      'p_keyword_type': keywordType,
    }, productId);
  }

  @override
  Future<ProductDetail> upsertMarketTranslation(
    ProductMarketTranslationCommand command,
  ) {
    return _mutate(
      CatalogRpcNames.upsertProductMarketTranslation,
      <String, Object?>{
        'p_product_id': command.productId,
        'p_locale': command.locale.databaseValue,
        'p_storage_conditions': command.storageConditions,
        'p_approved_indications': command.approvedIndications,
        'p_usual_adult_dose': command.usualAdultDose,
        'p_contraindications': command.contraindications,
        'p_common_adverse_effects': command.commonAdverseEffects,
      },
      command.productId,
    );
  }

  @override
  Future<ProductDetail> upsertMediaMetadata(
    ProductMediaMetadataCommand command,
  ) {
    return _mutate(
      CatalogRpcNames.upsertProductMediaMetadata,
      <String, Object?>{
        'p_media_id': command.mediaId,
        'p_product_id': command.productId,
        'p_media_type': command.type.databaseValue,
        'p_storage_path': command.storagePath,
        'p_mime_type': command.mimeType,
        'p_file_size_bytes': command.fileSizeBytes,
        'p_sort_order': command.sortOrder,
        'p_is_primary': command.isPrimary,
      },
      command.productId,
    );
  }

  @override
  Future<ProductDetail> upsertTranslation({
    required String productId,
    required ContentLocale locale,
    required String brandName,
  }) {
    return _mutate(CatalogRpcNames.upsertProductTranslation, <String, Object?>{
      'p_product_id': productId,
      'p_locale': locale.databaseValue,
      'p_brand_name': brandName,
    }, productId);
  }

  @override
  Future<ProductDetail> withdrawSubmission(String productId) {
    return _mutate(CatalogRpcNames.withdrawProductSubmission, <String, Object?>{
      'p_product_id': productId,
    }, productId);
  }

  Future<ProductDetail> _mutate(
    String rpc,
    Map<String, Object?> params,
    String productId,
  ) {
    return guardCatalogCall(() async {
      await _source.callRpc(rpc, params);
      return readProductDetail(_source, productId);
    });
  }

  Future<CatalogReadinessResult> _readiness(
    String productId,
    CatalogReadinessStage stage,
  ) async {
    final ProductDetail product = await getOwnProductDetail(productId);
    return CatalogReadinessEvaluator.evaluate(product, stage);
  }

  CatalogStorageDataSource _requireStorage() {
    final CatalogStorageDataSource? storage = _storage;
    if (storage == null) {
      throw const CatalogFailure(
        kind: CatalogFailureKind.serviceUnavailable,
        diagnosticCode: 'catalog_storage_unavailable',
      );
    }
    return storage;
  }

  void _validateUploadFile(
    CatalogUploadFile file, {
    required Set<String> allowedMimeTypes,
    required int maxBytes,
  }) {
    if (file.fileName.trim().isEmpty ||
        file.bytes.isEmpty ||
        file.bytes.length > maxBytes ||
        !allowedMimeTypes.contains(file.mimeType.toLowerCase())) {
      throw const CatalogFailure(
        kind: CatalogFailureKind.validation,
        diagnosticCode: 'invalid_catalog_upload',
      );
    }
  }

  Future<void> _removeFailedUpload(
    CatalogStorageDataSource storage,
    String bucket,
    String path,
  ) async {
    try {
      await storage.remove(bucket: bucket, path: path);
    } on Object {
      // Preserve the authoritative metadata failure for the caller.
    }
  }

  String _storagePath(String productId, String mimeType) {
    final String extension = switch (mimeType.toLowerCase()) {
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      'image/webp' => 'webp',
      'application/pdf' => 'pdf',
      _ => 'bin',
    };
    final String nonce =
        '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
    return '$productId/$nonce.$extension';
  }
}
