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
