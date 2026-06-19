import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';

void main() {
  test('product detail supports optional media and brochure metadata', () {
    final ProductDetail detail = _productDetail();

    expect(detail.media, isEmpty);
    expect(detail.brochures, isEmpty);
    expect(detail.markets, isEmpty);
    expect(detail.iraqMarket, isNull);
  });

  test('product detail collections are immutable', () {
    final ProductDetail detail = _productDetail();

    expect(() => detail.media.add(_media()), throwsUnsupportedError);
    expect(() => detail.brochures.add(_brochure()), throwsUnsupportedError);
  });

  test('lifecycle metadata keeps state-specific values nullable', () {
    const ProductLifecycleMetadata lifecycle = ProductLifecycleMetadata();

    expect(lifecycle.submittedAt, isNull);
    expect(lifecycle.publishedAt, isNull);
    expect(lifecycle.hiddenReason, isNull);
    expect(lifecycle.archiveReason, isNull);
  });
}

ProductDetail _productDetail() {
  final DateTime timestamp = DateTime.utc(2026, 6, 19);
  const TaxonomyTranslation className = TaxonomyTranslation(
    locale: ContentLocale.english,
    name: 'Class',
  );
  const DrugClass drugClass = DrugClass(
    id: 'class',
    code: 'class_code',
    isActive: true,
    translations: LocalizedContent<TaxonomyTranslation>(english: className),
  );
  const CatalogCompanySummary company = CatalogCompanySummary(
    id: 'company',
    companyName: 'Company',
    legalName: 'Company LLC',
    countryId: 'iraq',
    status: CompanyStatus.verified,
  );
  final ProductTranslation translation = ProductTranslation(
    id: 'translation',
    locale: ContentLocale.english,
    brandName: 'Brand',
    createdAt: timestamp,
    updatedAt: timestamp,
  );

  return ProductDetail(
    id: 'product',
    company: company,
    drugClass: drugClass,
    category: ProductCategory.dietarySupplement,
    status: ProductLifecycleStatus.draft,
    lifecycle: const ProductLifecycleMetadata(),
    translations: LocalizedContent<ProductTranslation>(english: translation),
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

ProductMediaMetadata _media() {
  final DateTime timestamp = DateTime.utc(2026, 6, 19);
  return ProductMediaMetadata(
    id: 'media',
    type: ProductMediaType.productImage,
    storagePath: 'metadata/path',
    mimeType: 'image/png',
    fileSizeBytes: 1,
    sortOrder: 0,
    isPrimary: true,
    uploadedBy: 'profile',
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

ProductBrochureMetadata _brochure() {
  final DateTime timestamp = DateTime.utc(2026, 6, 19);
  return ProductBrochureMetadata(
    id: 'brochure',
    productMarketId: 'market',
    locale: ContentLocale.english,
    title: 'Brochure',
    storagePath: 'metadata/path',
    mimeType: 'application/pdf',
    fileSizeBytes: 1,
    version: 1,
    isCurrent: true,
    uploadedBy: 'profile',
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}
