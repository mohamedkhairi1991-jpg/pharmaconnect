import '../../domain/failure/catalog_failure.dart';
import '../../domain/product/product_detail.dart';
import '../../domain/product/product_summary.dart';
import '../dto/product_dtos.dart';
import '../error/supabase_catalog_failure_mapper.dart';
import '../mapping/product_detail_mapper.dart';
import '../mapping/product_summary_mapper.dart';
import '../query/catalog_query_projections.dart';
import '../source/catalog_data_source.dart';

Future<ProductDetail> readProductDetail(
  CatalogDataSource source,
  String productId, {
  Map<String, Object> additionalFilters = const <String, Object>{},
}) {
  return guardCatalogCall(() async {
    final Map<String, Object?>? row = await source.readMaybeSingle(
      CatalogReadRequest(
        table: CatalogTables.products,
        projection: CatalogQueryProjections.product,
        filters: <String, Object>{
          'id': productId,
          'product_markets.country_id': CatalogReferenceIds.iraqCountryId,
          ...additionalFilters,
        },
      ),
    );
    if (row == null) {
      throw const CatalogFailure(
        kind: CatalogFailureKind.notFound,
        diagnosticCode: 'product_not_found',
      );
    }
    return ProductDetailMapper.map(ProductDto.fromJson(row));
  });
}

Future<List<ProductSummary>> readProductSummaries(
  CatalogDataSource source,
  CatalogReadRequest request,
) {
  return guardCatalogCall(() async {
    final List<Map<String, Object?>> rows = await source.readMany(request);
    return List<ProductSummary>.unmodifiable(
      rows.map(
        (Map<String, Object?> row) =>
            ProductSummaryMapper.map(ProductDto.fromJson(row)),
      ),
    );
  });
}

Future<String> currentCompanyId(CatalogDataSource source) async {
  final Map<String, Object?>? membership = await source.readMaybeSingle(
    const CatalogReadRequest(
      table: CatalogTables.companyUsers,
      projection: 'company_id',
    ),
  );
  final Object? value = membership?['company_id'];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw const CatalogFailure(
    kind: CatalogFailureKind.unauthorized,
    diagnosticCode: 'active_verified_company_membership_required',
  );
}
