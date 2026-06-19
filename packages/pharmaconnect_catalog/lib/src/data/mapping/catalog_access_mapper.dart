import '../../domain/access/catalog_company_access.dart';
import '../../domain/access/healthcare_professional_eligibility_summary.dart';
import '../dto/access_dtos.dart';

abstract final class CatalogAccessMapper {
  static HealthcareProfessionalEligibilitySummary professional(
    HealthcareProfessionalEligibilityDto dto,
  ) => dto.toDomain();

  static CatalogCompanyAccess company(CatalogCompanyAccessDto dto) =>
      dto.toDomain();
}
