import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';
import 'package:pharmaconnect_mobile/features/catalog/presentation/catalog_entry_pages.dart';

void main() {
  testWidgets('product card tap navigates to product detail route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _providerOverrides(
          repository: _FakeOfficialCatalogRepository(
            products: <ProductSummary>[_productSummary()],
            detail: _productDetail(),
          ),
        ),
        child: MaterialApp.router(
          theme: PharmaConnectTheme.dark(),
          routerConfig: _testRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('AeroCure'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AeroCure'));
    await tester.pumpAndSettle();

    expect(find.text('Official product detail'), findsOneWidget);
    expect(find.text('AeroCure'), findsOneWidget);
    expect(find.text('PharmaConnect Labs'), findsOneWidget);
  });

  testWidgets('product detail shows loading state', (
    WidgetTester tester,
  ) async {
    await _pumpDetail(
      tester,
      repository: _FakeOfficialCatalogRepository(
        detailCompleter: Completer<ProductDetail>(),
      ),
    );

    expect(find.text('Loading product detail'), findsOneWidget);
  });

  testWidgets('product detail shows error state', (WidgetTester tester) async {
    await _pumpDetail(
      tester,
      repository: _FakeOfficialCatalogRepository(
        detailError: Exception('detail failed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Product detail could not load'), findsOneWidget);
  });

  testWidgets('product detail data renders brand generic and company safely', (
    WidgetTester tester,
  ) async {
    await _pumpDetail(
      tester,
      repository: _FakeOfficialCatalogRepository(detail: _productDetail()),
    );
    await tester.pumpAndSettle();

    expect(find.text('AeroCure'), findsOneWidget);
    expect(find.text('Salbutamol'), findsWidgets);
    expect(find.text('PharmaConnect Labs'), findsOneWidget);
    expect(find.text('Product basics'), findsOneWidget);
    expect(find.text('Clinical information'), findsOneWidget);
  });

  testWidgets('product detail missing optional fields do not crash', (
    WidgetTester tester,
  ) async {
    await _pumpDetail(
      tester,
      repository: _FakeOfficialCatalogRepository(
        detail: _productDetail(includeOptionalFields: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AeroCure'), findsOneWidget);
    expect(find.text('Generic name not recorded'), findsOneWidget);
    expect(find.text('Product basics'), findsOneWidget);
  });

  testWidgets('product detail uses responsive web sections', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpDetail(
      tester,
      repository: _FakeOfficialCatalogRepository(detail: _productDetail()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('doctor-product-detail-grid')), findsOneWidget);
    expect(find.byKey(const Key('doctor-product-detail-list')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product detail avoids prohibited commercial wording', (
    WidgetTester tester,
  ) async {
    await _pumpDetail(
      tester,
      repository: _FakeOfficialCatalogRepository(detail: _productDetail()),
    );
    await tester.pumpAndSettle();

    final RegExp prohibitedWords = RegExp(
      r'\b(stock|price|order|orders|seller|pharmacy|pharmacies|availability|available)\b',
      caseSensitive: false,
    );
    final String textSnapshot = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text text) => text.data ?? '')
        .join('\n');

    expect(prohibitedWords.hasMatch(textSnapshot), isFalse);
  });
}

GoRouter _testRouter() {
  return GoRouter(
    initialLocation: '/catalog',
    routes: <RouteBase>[
      GoRoute(
        path: '/catalog',
        builder: (BuildContext context, GoRouterState state) =>
            const MobileOfficialCatalogEntryPage(),
      ),
      GoRoute(
        path: '/catalog/products/:productId',
        builder: (BuildContext context, GoRouterState state) =>
            MobileOfficialCatalogProductDetailPage(
              productId: state.pathParameters['productId'] ?? '',
            ),
      ),
    ],
  );
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  required _FakeOfficialCatalogRepository repository,
  String productId = 'product-id',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: _providerOverrides(repository: repository),
      child: MaterialApp(
        theme: PharmaConnectTheme.dark(),
        home: MobileOfficialCatalogProductDetailPage(productId: productId),
      ),
    ),
  );
  await tester.pump();
}

List<Override> _providerOverrides({
  required _FakeOfficialCatalogRepository repository,
}) {
  return <Override>[
    catalogAccessStateProvider.overrideWithValue(
      const AsyncData<CatalogAccessState>(
        CatalogAccessState(CatalogAudience.officialCatalog),
      ),
    ),
    officialCatalogRepositoryProvider.overrideWithValue(repository),
  ];
}

ProductSummary _productSummary() {
  final ProductDetail detail = _productDetail();
  return ProductSummary(
    id: detail.id,
    company: detail.company,
    genericDrug: detail.genericDrug,
    drugClass: detail.drugClass,
    category: detail.category,
    status: detail.status,
    translations: detail.translations,
    iraqMarket: detail.iraqMarket,
    updatedAt: detail.updatedAt,
  );
}

ProductDetail _productDetail({bool includeOptionalFields = true}) {
  final DateTime timestamp = DateTime.utc(2026, 6, 1);
  final DrugClass drugClass = DrugClass(
    id: 'respiratory',
    code: 'respiratory',
    isActive: true,
    translations: LocalizedContent<TaxonomyTranslation>(
      english: TaxonomyTranslation(
        locale: ContentLocale.english,
        name: 'Respiratory',
      ),
    ),
  );
  final ActiveIngredient activeIngredient = ActiveIngredient(
    id: 'ingredient-id',
    code: 'salbutamol',
    isActive: true,
    translations: LocalizedContent<TaxonomyTranslation>(
      english: TaxonomyTranslation(
        locale: ContentLocale.english,
        name: 'Salbutamol',
      ),
    ),
  );
  final ProductMarket market = ProductMarket(
    id: 'market-id',
    countryId: 'iq',
    strength: '100 mcg',
    dosageForm: 'inhaler',
    route: 'inhalation',
    packSize: '1 unit',
    marketStatus: IraqMarketStatus.marketedInIraq,
    registrationStatus: ProductRegistrationStatus.registered,
    registrationNumber: 'IQ-123',
    registrationAuthority: 'Iraq registration authority',
    translations: LocalizedContent<ProductMarketTranslation>(
      english: ProductMarketTranslation(
        id: 'market-translation-id',
        locale: ContentLocale.english,
        storageConditions: 'Store according to the official label.',
        approvedIndications: 'Indication text from official catalog data.',
        usualAdultDose: 'Dose text from official catalog data.',
        contraindications: 'Contraindication text from official catalog data.',
        commonAdverseEffects: 'Safety text from official catalog data.',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ),
    createdAt: timestamp,
    updatedAt: timestamp,
  );

  return ProductDetail(
    id: 'product-id',
    company: const CatalogCompanySummary(
      id: 'company-id',
      companyName: 'PharmaConnect Labs',
      legalName: 'PharmaConnect Labs LLC',
      countryId: 'iq',
      status: CompanyStatus.verified,
    ),
    genericDrug: includeOptionalFields
        ? GenericDrug(
            id: 'generic-id',
            code: 'salbutamol',
            drugClass: drugClass,
            isActive: true,
            translations: LocalizedContent<TaxonomyTranslation>(
              english: TaxonomyTranslation(
                locale: ContentLocale.english,
                name: 'Salbutamol',
              ),
            ),
            composition: <GenericCompositionEntry>[
              GenericCompositionEntry(
                ingredient: activeIngredient,
                sortOrder: 1,
              ),
            ],
          )
        : null,
    drugClass: drugClass,
    category: ProductCategory.prescriptionDrug,
    status: ProductLifecycleStatus.published,
    lifecycle: ProductLifecycleMetadata(publishedAt: timestamp),
    translations: LocalizedContent<ProductTranslation>(
      english: ProductTranslation(
        id: 'translation-id',
        locale: ContentLocale.english,
        brandName: 'AeroCure',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ),
    markets: includeOptionalFields ? <ProductMarket>[market] : const [],
    media: includeOptionalFields
        ? <ProductMediaMetadata>[
            ProductMediaMetadata(
              id: 'media-id',
              type: ProductMediaType.productImage,
              storagePath: 'catalog/product-image.png',
              mimeType: 'image/png',
              fileSizeBytes: 1024,
              sortOrder: 1,
              isPrimary: true,
              uploadedBy: 'user-id',
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          ]
        : const [],
    brochures: includeOptionalFields
        ? <ProductBrochureMetadata>[
            ProductBrochureMetadata(
              id: 'brochure-id',
              productMarketId: 'market-id',
              locale: ContentLocale.english,
              title: 'Official brochure',
              storagePath: 'catalog/brochure.pdf',
              mimeType: 'application/pdf',
              fileSizeBytes: 2048,
              version: 1,
              isCurrent: true,
              uploadedBy: 'user-id',
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          ]
        : const [],
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

final class _FakeOfficialCatalogRepository
    implements OfficialCatalogRepository {
  _FakeOfficialCatalogRepository({
    this.products = const <ProductSummary>[],
    this.detail,
    this.detailError,
    this.detailCompleter,
  });

  final List<ProductSummary> products;
  final ProductDetail? detail;
  final Object? detailError;
  final Completer<ProductDetail>? detailCompleter;

  @override
  Future<List<ProductSummary>> listOfficialProducts(
    ProductListRequest request,
  ) async {
    return products;
  }

  @override
  Future<ProductDetail> getOfficialProductDetail(String productId) async {
    if (detailCompleter case final Completer<ProductDetail> value) {
      return value.future;
    }
    if (detailError case final Object value) {
      throw value;
    }
    return detail ?? _productDetail();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
