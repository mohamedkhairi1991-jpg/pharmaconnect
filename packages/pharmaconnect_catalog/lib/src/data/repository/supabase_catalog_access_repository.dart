import '../../domain/access/catalog_company_access.dart';
import '../../domain/access/healthcare_professional_eligibility_summary.dart';
import '../../domain/repository/catalog_repositories.dart';
import '../dto/access_dtos.dart';
import '../error/supabase_catalog_failure_mapper.dart';
import '../mapping/catalog_access_mapper.dart';
import '../query/catalog_query_projections.dart';
import '../source/catalog_data_source.dart';

final class SupabaseCatalogAccessRepository implements CatalogAccessRepository {
  const SupabaseCatalogAccessRepository(this._source);

  final CatalogDataSource _source;

  @override
  Future<HealthcareProfessionalEligibilitySummary?>
  getHealthcareProfessionalEligibility() {
    return guardCatalogCall(() async {
      final Map<String, Object?>? row = await _source.readMaybeSingle(
        const CatalogReadRequest(
          table: CatalogTables.healthcareProfessionals,
          projection: CatalogQueryProjections.professionalEligibility,
        ),
      );
      return row == null
          ? null
          : CatalogAccessMapper.professional(
              HealthcareProfessionalEligibilityDto.fromJson(row),
            );
    });
  }

  @override
  Future<CatalogCompanyAccess?> getCurrentCompanyAccess() {
    return guardCatalogCall(() async {
      final Map<String, Object?>? row = await _source.readMaybeSingle(
        const CatalogReadRequest(
          table: CatalogTables.companyUsers,
          projection: CatalogQueryProjections.companyAccess,
        ),
      );
      return row == null
          ? null
          : CatalogAccessMapper.company(CatalogCompanyAccessDto.fromJson(row));
    });
  }
}
