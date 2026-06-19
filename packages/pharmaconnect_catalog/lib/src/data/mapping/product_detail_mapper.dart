import '../../domain/catalog_enums.dart';
import '../../domain/failure/catalog_failure.dart';
import '../../domain/localization/localized_content.dart';
import '../../domain/product/product_detail.dart';
import '../../domain/product/product_market.dart';
import '../../domain/product/product_translation.dart';
import '../dto/product_dtos.dart';
import '../dto/taxonomy_dtos.dart';

abstract final class ProductDetailMapper {
  static ProductDetail map(ProductDto dto) {
    final LocalizedContent<ProductTranslation> translations = _mapTranslations(
      dto.translations,
    );
    final List<ProductMarket> markets = dto.markets
        .map((ProductMarketDto value) => value.toDomain())
        .toList(growable: false);

    if (dto.status == ProductLifecycleStatus.published) {
      if (!translations.hasRequiredEnglish) {
        throw const CatalogFailure.incompatibleData(
          diagnosticCode: 'published_product_missing_english_translation',
        );
      }
      if (markets.isEmpty || !markets.first.translations.hasRequiredEnglish) {
        throw const CatalogFailure.incompatibleData(
          diagnosticCode: 'published_product_missing_english_market_content',
        );
      }
    }

    return ProductDetail(
      id: dto.id,
      company: dto.company.toDomain(),
      genericDrug: dto.genericDrug?.toDomain(),
      drugClass: dto.drugClass.toDomain(),
      category: dto.category,
      status: dto.status,
      lifecycle: dto.lifecycle,
      translations: translations,
      markets: markets,
      specialties: dto.specialties.map(
        (ProductSpecialtyDto value) => value.toDomain(),
      ),
      media: dto.media.map((ProductMediaMetadataDto value) => value.toDomain()),
      brochures: dto.brochures.map(
        (ProductBrochureMetadataDto value) => value.toDomain(),
      ),
      presentationFingerprint: dto.presentationFingerprint,
      createdAt: dto.createdAt,
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
