import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';

import 'support/catalog_fixtures.dart';

void main() {
  test(
    'official repository applies published filter and product projection',
    () async {
      final _FakeCatalogDataSource source = _FakeCatalogDataSource()
        ..manyResponses.add(<Map<String, Object?>>[publishedProductJson()]);
      final SupabaseOfficialCatalogRepository repository =
          SupabaseOfficialCatalogRepository(source);

      final List<ProductSummary> products = await repository
          .listOfficialProducts(
            const ProductListRequest(limit: 20, offset: 10),
          );

      expect(products, hasLength(1));
      expect(source.readRequests.single.table, CatalogTables.products);
      expect(
        source.readRequests.single.filters['status'],
        ProductLifecycleStatus.published.databaseValue,
      );
      expect(
        source.readRequests.single.filters['product_markets.country_id'],
        CatalogReferenceIds.iraqCountryId,
      );
      expect(
        source.readRequests.single.projection,
        CatalogQueryProjections.product,
      );
      expect(source.readRequests.single.limit, 20);
      expect(source.readRequests.single.offset, 10);
    },
  );

  test(
    'professional access selects the owning profile relationship explicitly',
    () async {
      final _FakeCatalogDataSource source = _FakeCatalogDataSource()
        ..singleResponses.add(<String, Object?>{
          'id': 'professional-id',
          'profile_id': 'profile-id',
          'profession_type': 'physician',
          'specialty_id': 'specialty-id',
          'verification_status': 'approved',
          'profiles': <String, Object?>{'status': 'active'},
        });
      final SupabaseCatalogAccessRepository repository =
          SupabaseCatalogAccessRepository(source);

      final HealthcareProfessionalEligibilitySummary? eligibility =
          await repository.getHealthcareProfessionalEligibility();

      expect(eligibility, isNotNull);
      expect(
        source.readRequests.single.projection,
        contains(
          'profiles!healthcare_professionals_profile_id_fkey!inner(status)',
        ),
      );
      expect(
        source.readRequests.single.projection,
        isNot(contains('profiles!inner(status)')),
      );
    },
  );

  test(
    'company access selects the member profile relationship explicitly',
    () async {
      final _FakeCatalogDataSource source = _FakeCatalogDataSource()
        ..singleResponses.add(<String, Object?>{
          'id': 'membership-id',
          'company_id': 'company-id',
          'company_role': 'company_admin',
          'is_active': true,
          'companies': <String, Object?>{
            'company_name': 'Company',
            'status': 'verified',
          },
          'profiles': <String, Object?>{'status': 'active'},
        });
      final SupabaseCatalogAccessRepository repository =
          SupabaseCatalogAccessRepository(source);

      final CatalogCompanyAccess? access = await repository
          .getCurrentCompanyAccess();

      expect(access, isNotNull);
      expect(
        source.readRequests.single.projection,
        contains('profiles!company_users_profile_id_fkey!inner(status)'),
      );
      expect(
        source.readRequests.single.projection,
        isNot(contains('profiles!inner(status)')),
      );
    },
  );

  test('company draft creation uses exact RPC and parameters', () async {
    final _FakeCatalogDataSource source = _FakeCatalogDataSource()
      ..rpcResponses.add(<String, Object?>{'id': 'product-id'})
      ..singleResponses.add(publishedProductJson()..['status'] = 'draft');
    final SupabaseCompanyCatalogRepository repository =
        SupabaseCompanyCatalogRepository(source);

    await repository.createDraft(
      const CreateProductDraftCommand(
        companyId: 'company-id',
        category: ProductCategory.dietarySupplement,
        drugClassId: 'class-id',
        englishBrandName: 'Brand',
      ),
    );

    expect(source.rpcCalls.single.name, CatalogRpcNames.createProductDraft);
    expect(source.rpcCalls.single.params, <String, Object?>{
      'p_company_id': 'company-id',
      'p_category': 'dietary_supplement',
      'p_generic_drug_id': null,
      'p_drug_class_id': 'class-id',
      'p_english_brand_name': 'Brand',
    });
  });

  test('company media upload stores bytes before recording metadata', () async {
    final _FakeCatalogDataSource source = _FakeCatalogDataSource()
      ..rpcResponses.add(null)
      ..singleResponses.add(publishedProductJson()..['status'] = 'draft');
    final _FakeCatalogStorageDataSource storage =
        _FakeCatalogStorageDataSource();
    final SupabaseCompanyCatalogRepository repository =
        SupabaseCompanyCatalogRepository(source, storage);

    await repository.uploadProductMedia(
      productId: 'product-id',
      type: ProductMediaType.productImage,
      file: CatalogUploadFile(
        fileName: 'product.webp',
        mimeType: 'image/webp',
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
      ),
    );

    expect(storage.uploads, hasLength(1));
    expect(storage.uploads.single.bucket, 'catalog-product-media');
    expect(storage.uploads.single.path, startsWith('product-id/'));
    expect(source.rpcCalls.single.name, CatalogRpcNames.upsertProductMediaMetadata);
    expect(source.rpcCalls.single.params['p_storage_path'], storage.uploads.single.path);
    expect(source.rpcCalls.single.params['p_is_primary'], isTrue);
  });

  test('invalid catalog upload fails before storage is called', () async {
    final _FakeCatalogDataSource source = _FakeCatalogDataSource();
    final _FakeCatalogStorageDataSource storage =
        _FakeCatalogStorageDataSource();
    final SupabaseCompanyCatalogRepository repository =
        SupabaseCompanyCatalogRepository(source, storage);

    await expectLater(
      repository.uploadProductMedia(
        productId: 'product-id',
        type: ProductMediaType.productImage,
        file: CatalogUploadFile(
          fileName: 'unsafe.exe',
          mimeType: 'application/octet-stream',
          bytes: Uint8List.fromList(<int>[1]),
        ),
      ),
      throwsA(
        isA<CatalogFailure>().having(
          (CatalogFailure failure) => failure.kind,
          'kind',
          CatalogFailureKind.validation,
        ),
      ),
    );
    expect(storage.uploads, isEmpty);
    expect(source.rpcCalls, isEmpty);
  });

  test('RPC one-row list response is supported', () async {
    final _FakeCatalogDataSource source = _FakeCatalogDataSource()
      ..rpcResponses.add(<Object?>[
        <String, Object?>{'id': 'product-id'},
      ])
      ..singleResponses.add(publishedProductJson()..['status'] = 'draft');
    final SupabaseCompanyCatalogRepository repository =
        SupabaseCompanyCatalogRepository(source);

    final ProductDetail detail = await repository.createDraft(
      const CreateProductDraftCommand(
        companyId: 'company-id',
        category: ProductCategory.dietarySupplement,
        drugClassId: 'class-id',
        englishBrandName: 'Brand',
      ),
    );

    expect(detail.id, 'product-id');
  });

  test(
    'company list uses current company and optional status filters',
    () async {
      final _FakeCatalogDataSource source = _FakeCatalogDataSource()
        ..singleResponses.add(<String, Object?>{'company_id': 'company-id'})
        ..manyResponses.add(<Map<String, Object?>>[draftProductJson()]);
      final SupabaseCompanyCatalogRepository repository =
          SupabaseCompanyCatalogRepository(source);

      await repository.listOwnProducts(status: ProductLifecycleStatus.draft);

      expect(source.readRequests.last.filters, <String, Object>{
        'company_id': 'company-id',
        'product_markets.country_id': CatalogReferenceIds.iraqCountryId,
        'status': 'draft',
      });
    },
  );

  test('admin restore methods use explicit destination states', () async {
    final _FakeCatalogDataSource source = _FakeCatalogDataSource()
      ..rpcResponses.add(null)
      ..singleResponses.add(publishedProductJson());
    final SupabaseAdminCatalogRepository repository =
        SupabaseAdminCatalogRepository(source);

    await repository.restoreToPublished('product-id');

    expect(source.rpcCalls.single.name, CatalogRpcNames.adminRestoreProduct);
    expect(source.rpcCalls.single.params['p_destination_status'], 'published');
    expect(source.rpcCalls.single.params['p_reason'], isNull);
  });

  test('admin review queue uses requested lifecycle status', () async {
    final _FakeCatalogDataSource source = _FakeCatalogDataSource()
      ..manyResponses.add(<Map<String, Object?>>[]);
    final SupabaseAdminCatalogRepository repository =
        SupabaseAdminCatalogRepository(source);

    await repository.listProductsByStatus(ProductLifecycleStatus.submitted);

    expect(source.readRequests.single.filters['status'], 'submitted');
  });

  test(
    'taxonomy repository uses centralized table and projection constants',
    () async {
      final _FakeCatalogDataSource source = _FakeCatalogDataSource()
        ..manyResponses.add(<Map<String, Object?>>[drugClassJson()]);
      final SupabaseCatalogTaxonomyRepository repository =
          SupabaseCatalogTaxonomyRepository(source);

      await repository.listDrugClasses();

      expect(source.readRequests.single.table, CatalogTables.drugClasses);
      expect(
        source.readRequests.single.projection,
        CatalogQueryProjections.drugClass,
      );
    },
  );

  test(
    'admin taxonomy repository uses implemented RPC names and parameters',
    () async {
      final _FakeCatalogDataSource source = _FakeCatalogDataSource()
        ..rpcResponses.add(<String, Object?>{'id': 'class-id'})
        ..singleResponses.add(drugClassJson());
      final SupabaseAdminCatalogTaxonomyRepository repository =
          SupabaseAdminCatalogTaxonomyRepository(source);

      await repository.createDrugClass('class_code', null);

      expect(source.rpcCalls.single.name, CatalogRpcNames.adminCreateDrugClass);
      expect(source.rpcCalls.single.params, <String, Object?>{
        'p_code': 'class_code',
        'p_parent_drug_class_id': null,
      });
      expect(source.readRequests.single.filters, <String, Object>{
        'id': 'class-id',
      });
    },
  );

  test('no query projection contains raw SQL statements', () {
    const List<String> projections = <String>[
      CatalogQueryProjections.product,
      CatalogQueryProjections.drugClass,
      CatalogQueryProjections.genericDrug,
      CatalogQueryProjections.professionalEligibility,
      CatalogQueryProjections.companyAccess,
    ];

    for (final String projection in projections) {
      expect(projection.toLowerCase(), isNot(contains('select ')));
      expect(projection.toLowerCase(), isNot(contains(' from ')));
    }
  });
}

final class _RpcCall {
  const _RpcCall(this.name, this.params);

  final String name;
  final Map<String, Object?> params;
}

final class _StorageUpload {
  const _StorageUpload(this.bucket, this.path, this.mimeType);

  final String bucket;
  final String path;
  final String mimeType;
}

final class _FakeCatalogStorageDataSource implements CatalogStorageDataSource {
  final List<_StorageUpload> uploads = <_StorageUpload>[];
  final List<_StorageUpload> removals = <_StorageUpload>[];

  @override
  Future<void> uploadBinary({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    uploads.add(_StorageUpload(bucket, path, mimeType));
  }

  @override
  Future<void> remove({required String bucket, required String path}) async {
    removals.add(_StorageUpload(bucket, path, ''));
  }
}

final class _FakeCatalogDataSource implements CatalogDataSource {
  final List<CatalogReadRequest> readRequests = <CatalogReadRequest>[];
  final List<List<Map<String, Object?>>> manyResponses =
      <List<Map<String, Object?>>>[];
  final List<Map<String, Object?>?> singleResponses = <Map<String, Object?>?>[];
  final List<Object?> rpcResponses = <Object?>[];
  final List<_RpcCall> rpcCalls = <_RpcCall>[];

  @override
  Future<Object?> callRpc(String name, Map<String, Object?> params) async {
    rpcCalls.add(_RpcCall(name, Map<String, Object?>.from(params)));
    return rpcResponses.isEmpty ? null : rpcResponses.removeAt(0);
  }

  @override
  Future<List<Map<String, Object?>>> readMany(
    CatalogReadRequest request,
  ) async {
    readRequests.add(request);
    return manyResponses.removeAt(0);
  }

  @override
  Future<Map<String, Object?>?> readMaybeSingle(
    CatalogReadRequest request,
  ) async {
    readRequests.add(request);
    return singleResponses.removeAt(0);
  }
}
