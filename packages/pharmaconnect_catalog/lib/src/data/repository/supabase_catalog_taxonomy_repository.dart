import '../../domain/failure/catalog_failure.dart';
import '../../domain/repository/catalog_repositories.dart';
import '../../domain/taxonomy/active_ingredient.dart';
import '../../domain/taxonomy/drug_class.dart';
import '../../domain/taxonomy/generic_drug.dart';
import '../../domain/taxonomy/product_specialty.dart';
import '../dto/taxonomy_dtos.dart';
import '../error/supabase_catalog_failure_mapper.dart';
import '../query/catalog_query_projections.dart';
import '../source/catalog_data_source.dart';

final class SupabaseCatalogTaxonomyRepository
    implements CatalogTaxonomyRepository {
  const SupabaseCatalogTaxonomyRepository(this._source);

  final CatalogDataSource _source;

  @override
  Future<GenericDrug> getGenericDrug(String id) {
    return guardCatalogCall(() async {
      final Map<String, Object?>? row = await _source.readMaybeSingle(
        CatalogReadRequest(
          table: CatalogTables.genericDrugs,
          projection: CatalogQueryProjections.genericDrug,
          filters: <String, Object>{'id': id},
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
  Future<List<ActiveIngredient>> listActiveIngredients() => _list(
    CatalogTables.activeIngredients,
    CatalogQueryProjections.activeIngredient,
    (Map<String, Object?> row) => ActiveIngredientDto.fromJson(row).toDomain(),
  );

  @override
  Future<List<DrugClass>> listDrugClasses() => _list(
    CatalogTables.drugClasses,
    CatalogQueryProjections.drugClass,
    (Map<String, Object?> row) => DrugClassDto.fromJson(row).toDomain(),
  );

  @override
  Future<List<GenericDrug>> listGenericDrugs() => _list(
    CatalogTables.genericDrugs,
    CatalogQueryProjections.genericDrug,
    (Map<String, Object?> row) => GenericDrugDto.fromJson(row).toDomain(),
  );

  @override
  Future<List<ProductSpecialty>> listSpecialties() => _list(
    CatalogTables.specialties,
    CatalogQueryProjections.specialty,
    (Map<String, Object?> row) => ProductSpecialtyDto.fromJson(row).toDomain(),
  );

  Future<List<T>> _list<T>(
    String table,
    String projection,
    T Function(Map<String, Object?>) mapper,
  ) {
    return guardCatalogCall(() async {
      final List<Map<String, Object?>> rows = await _source.readMany(
        CatalogReadRequest(
          table: table,
          projection: projection,
          filters: const <String, Object>{'is_active': true},
          orderBy: 'code',
        ),
      );
      return List<T>.unmodifiable(rows.map(mapper));
    });
  }
}
