import '../../domain/catalog_enums.dart';
import '../../domain/failure/catalog_failure.dart';
import '../../domain/localization/localized_content.dart';
import '../../domain/product/product_summary.dart';
import '../../domain/product/product_translation.dart';
import '../dto/product_dtos.dart';

abstract final class ProductSummaryMapper {
  static ProductSummary map(ProductDto dto) {
    final LocalizedContent<ProductTranslation> translations = _mapTranslations(
      dto.translations,
    );
    if (dto.status == ProductLifecycleStatus.published &&
        !translations.hasRequiredEnglish) {
      throw const CatalogFailure.incompatibleData(
        diagnosticCode: 'published_product_missing_english_translation',
      );
    }
    return ProductSummary(
      id: dto.id,
      company: dto.company.toDomain(),
      genericDrug: dto.genericDrug?.toDomain(),
      drugClass: dto.drugClass.toDomain(),
      category: dto.category,
      status: dto.status,
      translations: translations,
      iraqMarket: dto.markets.isEmpty ? null : dto.markets.first.toDomain(),
      updatedAt: dto.updatedAt,
    );
  }
}

LocalizedContent<ProductTranslation> _mapTranslations(
  Iterable<ProductTranslationDto> values,
) {
  ProductTranslation? english;
  ProductTranslation? arabic;
  for (final ProductTranslationDto value in values) {
    final ProductTranslation domain = value.toDomain();
    if (domain.locale == ContentLocale.english) {
      english = domain;
    } else {
      arabic = domain;
    }
  }
  return LocalizedContent<ProductTranslation>(english: english, arabic: arabic);
}
