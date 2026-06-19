import '../catalog_enums.dart';
import '../company/catalog_company_summary.dart';
import '../localization/localized_content.dart';
import '../taxonomy/drug_class.dart';
import '../taxonomy/generic_drug.dart';
import 'product_market.dart';
import 'product_translation.dart';

final class ProductSummary {
  const ProductSummary({
    required this.id,
    required this.company,
    required this.drugClass,
    required this.category,
    required this.status,
    required this.translations,
    required this.updatedAt,
    this.genericDrug,
    this.iraqMarket,
  });

  final String id;
  final CatalogCompanySummary company;
  final GenericDrug? genericDrug;
  final DrugClass drugClass;
  final ProductCategory category;
  final ProductLifecycleStatus status;
  final LocalizedContent<ProductTranslation> translations;
  final ProductMarket? iraqMarket;
  final DateTime updatedAt;
}
