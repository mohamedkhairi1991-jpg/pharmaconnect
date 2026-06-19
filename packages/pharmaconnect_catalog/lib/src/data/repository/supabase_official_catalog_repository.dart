import '../../domain/catalog_enums.dart';
import '../../domain/failure/catalog_failure.dart';
import '../../domain/product/product_detail.dart';
import '../../domain/product/product_summary.dart';
import '../../domain/repository/catalog_commands.dart';
import '../../domain/repository/catalog_repositories.dart';
import '../../domain/taxonomy/drug_class.dart';
import '../../domain/taxonomy/generic_drug.dart';
import '../dto/taxonomy_dtos.dart';
import '../error/supabase_catalog_failure_mapper.dart';
import '../query/catalog_query_projections.dart';
import '../source/catalog_data_source.dart';
import 'repository_support.dart';

final class SupabaseOfficialCatalogRepository
    implements OfficialCatalogRepository {
  const SupabaseOfficialCatalogRepository(this._source);

  final CatalogDataSource _source;

  @override
  Future<ProductDetail> getOfficialProductDetail(String productId) {
    return readProductDetail(
      _source,
      productId,
      additionalFilters: <String, Object>{
        'status': ProductLifecycleStatus.published.databaseValue,
      },
    );
  }

  @override
  Future<GenericDrug> getVisibleGenericDrug(String genericDrugId) {
    return guardCatalogCall(() async {
      final Map<String, Object?>? row = await _source.readMaybeSingle(
        CatalogReadRequest(
          table: CatalogTables.genericDrugs,
          projection: CatalogQueryProjections.genericDrug,
          filters: <String, Object>{'id': genericDrugId, 'is_active': true},
        ),
      );
      if (row == null) {
        throw const CatalogFailure(
          kind: CatalogFailureKind.notFound,
          diagnosticCode: 'generic_drug_not_found',
        );
      }
      return GenericDrugDto.fromJson(row).toDomain();
    });
  }

  @override
  Future<List<ProductSummary>> listOfficialProducts(
    ProductListRequest request,
  ) {
    return readProductSummaries(
      _source,
      CatalogReadRequest(
        table: CatalogTables.products,
        projection: CatalogQueryProjections.product,
        filters: <String, Object>{
          'status': ProductLifecycleStatus.published.databaseValue,
          'product_markets.country_id': CatalogReferenceIds.iraqCountryId,
        },
        orderBy: 'updated_at',
        ascending: false,
        limit: request.limit,
        offset: request.offset,
      ),
    );
  }

  @override
  Future<List<DrugClass>> listVisibleDrugClasses() {
    return guardCatalogCall(() async {
      final List<Map<String, Object?>> rows = await _source.readMany(
        const CatalogReadRequest(
          table: CatalogTables.drugClasses,
          projection: CatalogQueryProjections.drugClass,
          filters: <String, Object>{'is_active': true},
          orderBy: 'code',
        ),
      );
      return List<DrugClass>.unmodifiable(
        rows.map(
          (Map<String, Object?> row) => DrugClassDto.fromJson(row).toDomain(),
        ),
      );
    });
  }
}
