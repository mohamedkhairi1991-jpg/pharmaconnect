import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';

import 'support/catalog_fixtures.dart';

void main() {
  test('complete published DTO maps English-only official content', () {
    final ProductDto dto = ProductDto.fromJson(publishedProductJson());
    final ProductDetail detail = ProductDetailMapper.map(dto);

    expect(detail.status, ProductLifecycleStatus.published);
    expect(
      detail.translations.resolve(ContentLocale.arabic)?.brandName,
      'English Brand',
    );
    expect(detail.iraqMarket?.registrationNumber, isNull);
    expect(detail.media, isEmpty);
    expect(detail.brochures, isEmpty);
    expect(detail.createdAt.isUtc, isTrue);
  });

  test('English and Arabic content map independently', () {
    final ProductDetail detail = ProductDetailMapper.map(
      ProductDto.fromJson(publishedProductJson(includeArabic: true)),
    );

    expect(
      detail.translations.resolve(ContentLocale.arabic)?.brandName,
      'Arabic Brand',
    );
    expect(
      detail.translations.resolve(ContentLocale.english)?.brandName,
      'English Brand',
    );
  });

  test('partial draft keeps legitimate nullable fields and empty children', () {
    final ProductDetail detail = ProductDetailMapper.map(
      ProductDto.fromJson(draftProductJson()),
    );

    expect(detail.status, ProductLifecycleStatus.draft);
    expect(detail.presentationFingerprint, isNull);
    expect(detail.iraqMarket, isNull);
    expect(detail.specialties, isEmpty);
  });

  test('optional media and brochure metadata map when present', () {
    final ProductDetail detail = ProductDetailMapper.map(
      ProductDto.fromJson(
        publishedProductJson(includeMedia: true, includeBrochure: true),
      ),
    );

    expect(detail.media, hasLength(1));
    expect(detail.brochures, hasLength(1));
  });

  test('published record without required English content fails safely', () {
    final Map<String, Object?> json = publishedProductJson(includeArabic: true);
    json['product_translations'] = <Object?>[
      productTranslationJson('ar', 'Arabic Brand'),
    ];

    expect(
      () => ProductDetailMapper.map(ProductDto.fromJson(json)),
      throwsA(
        isA<CatalogFailure>().having(
          (CatalogFailure value) => value.kind,
          'kind',
          CatalogFailureKind.incompatibleData,
        ),
      ),
    );
  });

  test('unknown enum and malformed nested records are rejected', () {
    final Map<String, Object?> unknown = publishedProductJson();
    unknown['status'] = 'future_status';
    expect(() => ProductDto.fromJson(unknown), throwsA(isA<CatalogFailure>()));

    final Map<String, Object?> malformed = publishedProductJson();
    malformed['companies'] = 'not-an-object';
    expect(
      () => ProductDto.fromJson(malformed),
      throwsA(isA<CatalogFailure>()),
    );
  });

  test('summary mapper preserves official identity', () {
    final ProductSummary summary = ProductSummaryMapper.map(
      ProductDto.fromJson(publishedProductJson()),
    );

    expect(summary.id, 'product-id');
    expect(summary.company.companyName, 'Company');
    expect(summary.iraqMarket?.marketStatus, IraqMarketStatus.marketedInIraq);
  });

  test('catalog access mapper derives typed access summaries', () {
    final HealthcareProfessionalEligibilitySummary professional =
        CatalogAccessMapper.professional(
          HealthcareProfessionalEligibilityDto.fromJson(<String, Object?>{
            'id': 'professional-id',
            'profile_id': 'profile-id',
            'profession_type': 'physician',
            'specialty_id': 'specialty-id',
            'verification_status': 'approved',
            'profiles': <String, Object?>{'status': 'active'},
          }),
        );
    final CatalogCompanyAccess company = CatalogAccessMapper.company(
      CatalogCompanyAccessDto.fromJson(<String, Object?>{
        'id': 'membership-id',
        'company_id': 'company-id',
        'company_role': 'product_manager',
        'is_active': true,
        'companies': <String, Object?>{
          'company_name': 'Company',
          'status': 'verified',
        },
        'profiles': <String, Object?>{'status': 'active'},
      }),
    );

    expect(professional.isOfficialCatalogEligible, isTrue);
    expect(company.canManageDrafts, isTrue);
  });
}
