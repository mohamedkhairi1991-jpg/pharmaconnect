import '../../domain/catalog_enums.dart';
import '../../domain/failure/catalog_failure.dart';
import '../../domain/repository/catalog_repositories.dart';
import '../../domain/taxonomy/active_ingredient.dart';
import '../../domain/taxonomy/drug_class.dart';
import '../../domain/taxonomy/generic_drug.dart';
import '../../domain/taxonomy/product_specialty.dart';
import '../dto/taxonomy_dtos.dart';
import '../error/supabase_catalog_failure_mapper.dart';
import '../parsing/response_parser.dart';
import '../query/catalog_query_projections.dart';
import '../source/catalog_data_source.dart';

final class SupabaseAdminCatalogTaxonomyRepository
    implements AdminCatalogTaxonomyRepository {
  SupabaseAdminCatalogTaxonomyRepository(this._source);

  final CatalogDataSource _source;

  @override
  Future<ActiveIngredient> createActiveIngredient(String code) async {
    final String id = await _rpcId(
      CatalogRpcNames.adminCreateActiveIngredient,
      <String, Object?>{'p_code': code},
    );
    return _readIngredient(id);
  }

  @override
  Future<DrugClass> createDrugClass(String code, String? parentId) async {
    final String id = await _rpcId(
      CatalogRpcNames.adminCreateDrugClass,
      <String, Object?>{'p_code': code, 'p_parent_drug_class_id': parentId},
    );
    return _readDrugClass(id);
  }

  @override
  Future<GenericDrug> createGenericDrug(String code, String drugClassId) async {
    final String id = await _rpcId(
      CatalogRpcNames.adminCreateGenericDrug,
      <String, Object?>{'p_code': code, 'p_drug_class_id': drugClassId},
    );
    return _readGenericDrug(id);
  }

  @override
  Future<ProductSpecialty> createSpecialty(
    String code,
    ProfessionType? professionType,
  ) async {
    final String id = await _rpcId(
      CatalogRpcNames.adminCreateSpecialty,
      <String, Object?>{
        'p_code': code,
        'p_profession_type': professionType?.databaseValue,
      },
    );
    return _readSpecialty(id);
  }

  @override
  Future<ActiveIngredient> setActiveIngredientActive(
    String id,
    bool isActive,
  ) async {
    await _source.callRpc(
      CatalogRpcNames.adminSetActiveIngredientActive,
      <String, Object?>{'p_active_ingredient_id': id, 'p_is_active': isActive},
    );
    return _readIngredient(id);
  }

  @override
  Future<DrugClass> setDrugClassActive(String id, bool isActive) async {
    await _source.callRpc(
      CatalogRpcNames.adminSetDrugClassActive,
      <String, Object?>{'p_drug_class_id': id, 'p_is_active': isActive},
    );
    return _readDrugClass(id);
  }

  @override
  Future<GenericDrug> setGenericDrugActive(String id, bool isActive) async {
    await _source.callRpc(
      CatalogRpcNames.adminSetGenericDrugActive,
      <String, Object?>{'p_generic_drug_id': id, 'p_is_active': isActive},
    );
    return _readGenericDrug(id);
  }

  @override
  Future<void> setGenericDrugIngredients(
    String id,
    List<String> ingredientIds,
  ) {
    return guardCatalogCall(() async {
      await _source.callRpc(
        CatalogRpcNames.adminSetGenericDrugIngredients,
        <String, Object?>{
          'p_generic_drug_id': id,
          'p_active_ingredient_ids': ingredientIds,
        },
      );
    });
  }

  @override
  Future<ProductSpecialty> setSpecialtyActive(String id, bool isActive) async {
    await _source.callRpc(
      CatalogRpcNames.adminSetSpecialtyActive,
      <String, Object?>{'p_specialty_id': id, 'p_is_active': isActive},
    );
    return _readSpecialty(id);
  }

  @override
  Future<ActiveIngredient> updateActiveIngredient(
    String id,
    String code,
  ) async {
    await _source.callRpc(
      CatalogRpcNames.adminUpdateActiveIngredient,
      <String, Object?>{'p_active_ingredient_id': id, 'p_code': code},
    );
    return _readIngredient(id);
  }

  @override
  Future<DrugClass> updateDrugClass(
    String id,
    String code,
    String? parentId,
  ) async {
    await _source.callRpc(
      CatalogRpcNames.adminUpdateDrugClass,
      <String, Object?>{
        'p_drug_class_id': id,
        'p_code': code,
        'p_parent_drug_class_id': parentId,
      },
    );
    return _readDrugClass(id);
  }

  @override
  Future<GenericDrug> updateGenericDrug(
    String id,
    String code,
    String drugClassId,
  ) async {
    await _source.callRpc(
      CatalogRpcNames.adminUpdateGenericDrug,
      <String, Object?>{
        'p_generic_drug_id': id,
        'p_code': code,
        'p_drug_class_id': drugClassId,
      },
    );
    return _readGenericDrug(id);
  }

  @override
  Future<ProductSpecialty> updateSpecialty(
    String id,
    String code,
    ProfessionType? professionType,
  ) async {
    await _source
        .callRpc(CatalogRpcNames.adminUpdateSpecialty, <String, Object?>{
          'p_specialty_id': id,
          'p_code': code,
          'p_profession_type': professionType?.databaseValue,
        });
    return _readSpecialty(id);
  }

  @override
  Future<void> upsertActiveIngredientTranslation({
    required String id,
    required ContentLocale locale,
    required String name,
    String? description,
  }) => _translationRpc(
    CatalogRpcNames.adminUpsertActiveIngredientTranslation,
    'p_active_ingredient_id',
    id,
    locale,
    name,
    description,
  );

  @override
  Future<void> upsertDrugClassTranslation({
    required String id,
    required ContentLocale locale,
    required String name,
    String? description,
  }) => _translationRpc(
    CatalogRpcNames.adminUpsertDrugClassTranslation,
    'p_drug_class_id',
    id,
    locale,
    name,
    description,
  );

  @override
  Future<void> upsertGenericDrugTranslation({
    required String id,
    required ContentLocale locale,
    required String name,
    String? description,
  }) => _translationRpc(
    CatalogRpcNames.adminUpsertGenericDrugTranslation,
    'p_generic_drug_id',
    id,
    locale,
    name,
    description,
  );

  @override
  Future<void> upsertSpecialtyTranslation({
    required String id,
    required ContentLocale locale,
    required String name,
    String? description,
  }) => _translationRpc(
    CatalogRpcNames.adminUpsertSpecialtyTranslation,
    'p_specialty_id',
    id,
    locale,
    name,
    description,
  );

  Future<String> _rpcId(String name, Map<String, Object?> params) {
    return guardCatalogCall(() async {
      final Map<String, Object?> row = parseRpcObject(
        await _source.callRpc(name, params),
        name,
      );
      final Object? id = row['id'];
      if (id is String) {
        return id;
      }
      throw CatalogFailure.incompatibleData(
        diagnosticCode: '${name}_missing_id',
      );
    });
  }

  Future<ActiveIngredient> _readIngredient(String id) async {
    final Map<String, Object?> row = await _readTaxonomyRow(
      CatalogTables.activeIngredients,
      CatalogQueryProjections.activeIngredient,
      id,
      'active_ingredient_not_found',
    );
    return ActiveIngredientDto.fromJson(row).toDomain();
  }

  Future<DrugClass> _readDrugClass(String id) async {
    final Map<String, Object?> row = await _readTaxonomyRow(
      CatalogTables.drugClasses,
      CatalogQueryProjections.drugClass,
      id,
      'drug_class_not_found',
    );
    return DrugClassDto.fromJson(row).toDomain();
  }

  Future<GenericDrug> _readGenericDrug(String id) async {
    final Map<String, Object?> row = await _readTaxonomyRow(
      CatalogTables.genericDrugs,
      CatalogQueryProjections.genericDrug,
      id,
      'generic_drug_not_found',
    );
    return GenericDrugDto.fromJson(row).toDomain();
  }

  Future<ProductSpecialty> _readSpecialty(String id) async {
    final Map<String, Object?> row = await _readTaxonomyRow(
      CatalogTables.specialties,
      CatalogQueryProjections.specialty,
      id,
      'specialty_not_found',
    );
    return ProductSpecialtyDto.fromJson(row).toDomain();
  }

  Future<Map<String, Object?>> _readTaxonomyRow(
    String table,
    String projection,
    String id,
    String diagnosticCode,
  ) {
    return guardCatalogCall(() async {
      final Map<String, Object?>? row = await _source.readMaybeSingle(
        CatalogReadRequest(
          table: table,
          projection: projection,
          filters: <String, Object>{'id': id},
        ),
      );
      if (row == null) {
        throw CatalogFailure(
          kind: CatalogFailureKind.notFound,
          diagnosticCode: diagnosticCode,
        );
      }
      return row;
    });
  }

  Future<void> _translationRpc(
    String rpc,
    String idParameter,
    String id,
    ContentLocale locale,
    String name,
    String? description,
  ) {
    return guardCatalogCall(() async {
      await _source.callRpc(rpc, <String, Object?>{
        idParameter: id,
        'p_locale': locale.databaseValue,
        'p_name': name,
        'p_description': description,
      });
    });
  }
}
