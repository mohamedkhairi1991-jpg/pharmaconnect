import '../catalog_enums.dart';

final class CatalogCompanySummary {
  const CatalogCompanySummary({
    required this.id,
    required this.companyName,
    required this.legalName,
    required this.countryId,
    required this.status,
    this.cityId,
  });

  final String id;
  final String companyName;
  final String legalName;
  final String countryId;
  final String? cityId;
  final CompanyStatus status;
}
