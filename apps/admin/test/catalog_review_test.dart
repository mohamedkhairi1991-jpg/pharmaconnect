import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_admin/features/catalog/presentation/catalog_review_entry_page.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';

void main() {
  testWidgets('admin review queue renders Pharamty loading and empty states', (
    WidgetTester tester,
  ) async {
    final Completer<List<ProductSummary>> pending =
        Completer<List<ProductSummary>>();
    await _pumpReviewQueue(
      tester,
      repository: _FakeAdminCatalogRepository(listCompleter: pending),
    );

    expect(find.text('Pharamty'), findsOneWidget);
    expect(find.text('Loading review queue'), findsOneWidget);

    pending.complete(const <ProductSummary>[]);
    await tester.pumpAndSettle();

    expect(find.text('No submitted products'), findsOneWidget);
  });

  testWidgets('admin review queue renders a safe retryable error state', (
    WidgetTester tester,
  ) async {
    await _pumpReviewQueue(
      tester,
      repository: _FakeAdminCatalogRepository(
        listError: StateError('provider failed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Review queue could not load'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('submitted products render in responsive list and grid layouts', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpReviewQueue(
      tester,
      repository: _FakeAdminCatalogRepository(
        products: <ProductSummary>[
          _productSummary(),
          _productSummary(
            id: 'second-product',
            brandName: 'Airvento 100 mcg',
            genericName: 'Salbutamol',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('admin-review-list')), findsOneWidget);
    expect(find.byKey(const Key('admin-review-grid')), findsNothing);
    expect(find.text('Cardiostead 5 mg'), findsOneWidget);
    expect(
      find.text('Company: Tigris Pharma', findRichText: true),
      findsNWidgets(2),
    );
    expect(find.text('Submitted'), findsNWidgets(2));

    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('admin-review-grid')), findsOneWidget);
    expect(find.byKey(const Key('admin-review-list')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('submitted review detail renders safe catalog information', (
    WidgetTester tester,
  ) async {
    await _pumpReviewQueue(
      tester,
      repository: _FakeAdminCatalogRepository(
        products: <ProductSummary>[_productSummary()],
        detail: _productDetail(),
      ),
    );
    await tester.pumpAndSettle();

    final Finder openReview = find.byKey(
      const Key('admin-open-review-product-id'),
    );
    await tester.ensureVisible(openReview);
    await tester.pump();
    await tester.tap(openReview);
    await tester.pumpAndSettle();

    expect(find.text('Product review detail'), findsOneWidget);
    expect(find.text('Cardiostead 5 mg'), findsWidgets);
    expect(find.text('Bisoprolol'), findsWidgets);
    expect(
      find.text('Company: Tigris Pharma', findRichText: true),
      findsWidgets,
    );
    expect(find.text('Product basics'), findsOneWidget);
    expect(find.text('Review decision'), findsOneWidget);
    expect(find.byKey(const Key('admin-publish-button')), findsOneWidget);
    expect(
      find.byKey(const Key('admin-request-changes-button')),
      findsOneWidget,
    );
  });

  testWidgets('non-submitted product detail remains read-only', (
    WidgetTester tester,
  ) async {
    await _pumpReviewQueue(
      tester,
      repository: _FakeAdminCatalogRepository(
        products: <ProductSummary>[
          _productSummary(status: ProductLifecycleStatus.published),
        ],
        detail: _productDetail(status: ProductLifecycleStatus.published),
      ),
    );
    await tester.pumpAndSettle();

    final Finder openReview = find.byKey(
      const Key('admin-open-review-product-id'),
    );
    await tester.ensureVisible(openReview);
    await tester.pump();
    await tester.tap(openReview);
    await tester.pumpAndSettle();

    expect(find.text('Lifecycle actions unavailable'), findsOneWidget);
    expect(find.byKey(const Key('admin-publish-button')), findsNothing);
    expect(find.byKey(const Key('admin-request-changes-button')), findsNothing);
  });

  testWidgets('request changes requires a non-empty review reason', (
    WidgetTester tester,
  ) async {
    await _pumpReviewQueue(
      tester,
      repository: _FakeAdminCatalogRepository(
        products: <ProductSummary>[_productSummary()],
        detail: _productDetail(),
      ),
    );
    await tester.pumpAndSettle();

    final Finder openReview = find.byKey(
      const Key('admin-open-review-product-id'),
    );
    await tester.ensureVisible(openReview);
    await tester.pump();
    await tester.tap(openReview);
    await tester.pumpAndSettle();
    final Finder requestChanges = find.byKey(
      const Key('admin-request-changes-button'),
    );
    await tester.ensureVisible(requestChanges);
    await tester.pump();
    await tester.tap(requestChanges);
    await tester.pumpAndSettle();

    final Finder confirm = find.byKey(
      const Key('admin-confirm-request-changes-button'),
    );
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('admin-request-changes-reason')),
      'Clarify the official registration metadata.',
    );
    await tester.pump();

    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
  });

  testWidgets('admin review UI avoids excluded commercial terminology', (
    WidgetTester tester,
  ) async {
    await _pumpReviewQueue(
      tester,
      repository: _FakeAdminCatalogRepository(
        products: <ProductSummary>[_productSummary()],
      ),
    );
    await tester.pumpAndSettle();

    final RegExp excluded = RegExp(
      r'\b(price|pricing|stock|seller|pharmacy|ordering|order|availability|distributor|warehouse|sales representative|supplier tracking|supply-chain|supply chain)\b',
      caseSensitive: false,
    );
    final String visibleCopy = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text widget) => widget.data ?? '')
        .join('\n');

    expect(excluded.hasMatch(visibleCopy), isFalse);
  });
}

Future<void> _pumpReviewQueue(
  WidgetTester tester, {
  required _FakeAdminCatalogRepository repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        catalogAccessStateProvider.overrideWithValue(
          const AsyncData<CatalogAccessState>(
            CatalogAccessState(CatalogAudience.administrator),
          ),
        ),
        adminCatalogRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: PharmaConnectTheme.dark(),
        home: const AdminCatalogReviewEntryPage(),
      ),
    ),
  );
  await tester.pump();
}

ProductSummary _productSummary({
  String id = 'product-id',
  String brandName = 'Cardiostead 5 mg',
  String genericName = 'Bisoprolol',
  ProductLifecycleStatus status = ProductLifecycleStatus.submitted,
}) {
  final ProductDetail detail = _productDetail(
    id: id,
    brandName: brandName,
    genericName: genericName,
    status: status,
  );
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

ProductDetail _productDetail({
  String id = 'product-id',
  String brandName = 'Cardiostead 5 mg',
  String genericName = 'Bisoprolol',
  ProductLifecycleStatus status = ProductLifecycleStatus.submitted,
}) {
  final DateTime timestamp = DateTime.utc(2026, 7, 17);
  final DrugClass drugClass = DrugClass(
    id: '$id-class',
    code: 'beta-blockers',
    isActive: true,
    translations: const LocalizedContent<TaxonomyTranslation>(
      english: TaxonomyTranslation(
        locale: ContentLocale.english,
        name: 'Beta Blockers',
      ),
    ),
  );
  final GenericDrug genericDrug = GenericDrug(
    id: '$id-generic',
    code: genericName.toLowerCase(),
    drugClass: drugClass,
    isActive: true,
    translations: LocalizedContent<TaxonomyTranslation>(
      english: TaxonomyTranslation(
        locale: ContentLocale.english,
        name: genericName,
      ),
    ),
    composition: const <GenericCompositionEntry>[],
  );
  final ProductMarket market = ProductMarket(
    id: '$id-market',
    countryId: 'iq',
    strength: '5 mg',
    dosageForm: 'Tablet',
    route: 'Oral',
    packSize: '30 tablets',
    marketStatus: IraqMarketStatus.marketedInIraq,
    registrationStatus: ProductRegistrationStatus.registered,
    registrationNumber: 'IQ-DEMO-001',
    registrationAuthority: 'Iraq registration authority',
    translations: const LocalizedContent<ProductMarketTranslation>(
      english: null,
    ),
    createdAt: timestamp,
    updatedAt: timestamp,
  );

  return ProductDetail(
    id: id,
    company: const CatalogCompanySummary(
      id: 'company-id',
      companyName: 'Tigris Pharma',
      legalName: 'Tigris Pharma LLC',
      countryId: 'iq',
      status: CompanyStatus.verified,
    ),
    genericDrug: genericDrug,
    drugClass: drugClass,
    category: ProductCategory.prescriptionDrug,
    status: status,
    lifecycle: ProductLifecycleMetadata(
      submittedAt: status == ProductLifecycleStatus.submitted
          ? timestamp
          : null,
      publishedAt: status == ProductLifecycleStatus.published
          ? timestamp
          : null,
    ),
    translations: LocalizedContent<ProductTranslation>(
      english: ProductTranslation(
        id: '$id-translation',
        locale: ContentLocale.english,
        brandName: brandName,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ),
    markets: <ProductMarket>[market],
    media: const <ProductMediaMetadata>[],
    brochures: const <ProductBrochureMetadata>[],
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

final class _FakeAdminCatalogRepository implements AdminCatalogRepository {
  _FakeAdminCatalogRepository({
    this.products = const <ProductSummary>[],
    this.detail,
    this.listError,
    this.listCompleter,
  });

  final List<ProductSummary> products;
  final ProductDetail? detail;
  final Object? listError;
  final Completer<List<ProductSummary>>? listCompleter;

  @override
  Future<List<ProductSummary>> listProductsByStatus(
    ProductLifecycleStatus status,
  ) async {
    if (listCompleter case final Completer<List<ProductSummary>> value) {
      return value.future;
    }
    if (listError case final Object value) {
      throw value;
    }
    return products;
  }

  @override
  Future<ProductDetail> getProductDetail(String productId) async {
    return detail ?? _productDetail(id: productId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
