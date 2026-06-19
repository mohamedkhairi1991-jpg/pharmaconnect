import '../../domain/catalog_enums.dart';
import '../../domain/product/product_detail.dart';
import '../../domain/product/product_summary.dart';
import '../../domain/repository/catalog_repositories.dart';
import '../error/supabase_catalog_failure_mapper.dart';
import '../query/catalog_query_projections.dart';
import '../source/catalog_data_source.dart';
import 'repository_support.dart';

final class SupabaseAdminCatalogRepository implements AdminCatalogRepository {
  const SupabaseAdminCatalogRepository(this._source);

  final CatalogDataSource _source;

  @override
  Future<ProductDetail> archive(String productId, String reason) => _mutate(
    CatalogRpcNames.adminArchiveProduct,
    <String, Object?>{'p_product_id': productId, 'p_reason': reason},
    productId,
  );

  @override
  Future<ProductDetail> getProductDetail(String productId) {
    return readProductDetail(_source, productId);
  }

  @override
  Future<ProductDetail> hide(String productId, String reason) => _mutate(
    CatalogRpcNames.adminHideProduct,
    <String, Object?>{'p_product_id': productId, 'p_reason': reason},
    productId,
  );

  @override
  Future<List<ProductSummary>> listProductsByStatus(
    ProductLifecycleStatus status,
  ) {
    return readProductSummaries(
      _source,
      CatalogReadRequest(
        table: CatalogTables.products,
        projection: CatalogQueryProjections.product,
        filters: <String, Object>{
          'status': status.databaseValue,
          'product_markets.country_id': CatalogReferenceIds.iraqCountryId,
        },
        orderBy: 'updated_at',
        ascending: false,
      ),
    );
  }

  @override
  Future<ProductDetail> publish(String productId) => _mutate(
    CatalogRpcNames.adminPublishProduct,
    <String, Object?>{'p_product_id': productId},
    productId,
  );

  @override
  Future<ProductDetail> requestChanges(String productId, String reason) =>
      _mutate(CatalogRpcNames.adminRequestProductChanges, <String, Object?>{
        'p_product_id': productId,
        'p_reason': reason,
      }, productId);

  @override
  Future<ProductDetail> restoreForChanges(String productId, String reason) =>
      _mutate(CatalogRpcNames.adminRestoreProduct, <String, Object?>{
        'p_product_id': productId,
        'p_destination_status':
            ProductLifecycleStatus.changesRequested.databaseValue,
        'p_reason': reason,
      }, productId);

  @override
  Future<ProductDetail> restoreToPublished(String productId) =>
      _mutate(CatalogRpcNames.adminRestoreProduct, <String, Object?>{
        'p_product_id': productId,
        'p_destination_status': ProductLifecycleStatus.published.databaseValue,
        'p_reason': null,
      }, productId);

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
}
