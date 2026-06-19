import '../catalog_enums.dart';
import '../company/catalog_company_summary.dart';
import '../localization/localized_content.dart';
import '../taxonomy/drug_class.dart';
import '../taxonomy/generic_drug.dart';
import '../taxonomy/product_specialty.dart';
import 'product_brochure_metadata.dart';
import 'product_lifecycle_metadata.dart';
import 'product_market.dart';
import 'product_media_metadata.dart';
import 'product_translation.dart';

final class ProductDetail {
  ProductDetail({
    required this.id,
    required this.company,
    required this.drugClass,
    required this.category,
    required this.status,
    required this.lifecycle,
    required this.translations,
    required this.createdAt,
    required this.updatedAt,
    Iterable<ProductMarket> markets = const <ProductMarket>[],
    Iterable<ProductSpecialty> specialties = const <ProductSpecialty>[],
    Iterable<ProductMediaMetadata> media = const <ProductMediaMetadata>[],
    Iterable<ProductBrochureMetadata> brochures =
        const <ProductBrochureMetadata>[],
    this.genericDrug,
    this.presentationFingerprint,
  }) : markets = List<ProductMarket>.unmodifiable(markets),
       specialties = List<ProductSpecialty>.unmodifiable(specialties),
       media = List<ProductMediaMetadata>.unmodifiable(media),
       brochures = List<ProductBrochureMetadata>.unmodifiable(brochures);

  final String id;
  final CatalogCompanySummary company;
  final GenericDrug? genericDrug;
  final DrugClass drugClass;
  final ProductCategory category;
  final ProductLifecycleStatus status;
  final ProductLifecycleMetadata lifecycle;
  final LocalizedContent<ProductTranslation> translations;
  final List<ProductMarket> markets;
  final List<ProductSpecialty> specialties;
  final List<ProductMediaMetadata> media;
  final List<ProductBrochureMetadata> brochures;
  final String? presentationFingerprint;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductMarket? get iraqMarket {
    return markets.isEmpty ? null : markets.first;
  }
}
