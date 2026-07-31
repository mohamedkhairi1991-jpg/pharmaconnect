import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';
import 'package:pharmaconnect_mobile/features/catalog/presentation/catalog_entry_pages.dart';

void main() {
  testWidgets('company catalog renders Pharamty loading and empty states', (
    WidgetTester tester,
  ) async {
    final Completer<List<ProductSummary>> pending =
        Completer<List<ProductSummary>>();
    await _pumpCompanyCatalog(
      tester,
      repository: _FakeCompanyCatalogRepository(listCompleter: pending),
    );

    expect(find.text('Pharamty'), findsOneWidget);
    expect(find.text('Loading company catalog'), findsOneWidget);

    pending.complete(const <ProductSummary>[]);
    await tester.pumpAndSettle();

    expect(find.text('No company products yet'), findsOneWidget);
  });

  testWidgets('company catalog renders a safe retryable error state', (
    WidgetTester tester,
  ) async {
    await _pumpCompanyCatalog(
      tester,
      repository: _FakeCompanyCatalogRepository(
        listError: StateError('provider failed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Company catalog could not load'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('company catalog shows product status and workflow cues', (
    WidgetTester tester,
  ) async {
    await _pumpCompanyCatalog(
      tester,
      repository: _FakeCompanyCatalogRepository(
        products: <ProductSummary>[
          _productSummary(
            id: 'draft-id',
            brandName: 'Airvento 100 mcg',
            status: ProductLifecycleStatus.draft,
          ),
          _productSummary(
            id: 'submitted-id',
            brandName: 'Cardiostead 5 mg',
            status: ProductLifecycleStatus.submitted,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Airvento 100 mcg'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Complete required product information'), findsOneWidget);
    expect(find.text('Cardiostead 5 mg'), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('Awaiting official catalog review'), findsOneWidget);
  });

  testWidgets('company catalog uses list on phone and grid on web', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final _FakeCompanyCatalogRepository repository =
        _FakeCompanyCatalogRepository(
          products: <ProductSummary>[_productSummary()],
        );
    await _pumpCompanyCatalog(tester, repository: repository);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('company-catalog-list')), findsOneWidget);
    expect(find.byKey(const Key('company-catalog-grid')), findsNothing);

    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('company-catalog-grid')), findsOneWidget);
    expect(find.byKey(const Key('company-catalog-list')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('create draft action opens the provider-backed minimal form', (
    WidgetTester tester,
  ) async {
    await _pumpCompanyCatalog(
      tester,
      repository: _FakeCompanyCatalogRepository(),
      includeDraftProviders: true,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('company-create-draft-button')));
    await tester.pumpAndSettle();

    expect(find.text('Create product draft'), findsWidgets);
    expect(find.text('English brand name'), findsOneWidget);
    expect(find.text('Product category'), findsOneWidget);
    expect(find.text('Drug class'), findsOneWidget);
  });

  testWidgets('draft detail is editable and submitted detail is read-only', (
    WidgetTester tester,
  ) async {
    final _FakeCompanyCatalogRepository draftRepository =
        _FakeCompanyCatalogRepository(
          products: <ProductSummary>[
            _productSummary(status: ProductLifecycleStatus.draft),
          ],
          detail: _productDetail(status: ProductLifecycleStatus.draft),
        );
    await _pumpCompanyCatalog(tester, repository: draftRepository);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Airvento 100 mcg'));
    await tester.tap(find.text('Airvento 100 mcg'));
    await tester.pumpAndSettle();

    expect(find.text('Product completion'), findsOneWidget);
    expect(find.text('Save workflow changes'), findsOneWidget);
    expect(find.text('Ready for review'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    final _FakeCompanyCatalogRepository submittedRepository =
        _FakeCompanyCatalogRepository(
          products: <ProductSummary>[
            _productSummary(status: ProductLifecycleStatus.submitted),
          ],
          detail: _productDetail(status: ProductLifecycleStatus.submitted),
        );
    await _pumpCompanyCatalog(tester, repository: submittedRepository);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Airvento 100 mcg'));
    await tester.tap(find.text('Airvento 100 mcg'));
    await tester.pumpAndSettle();

    expect(find.text('Read-only workflow item'), findsOneWidget);
    expect(find.text('Save workflow changes'), findsNothing);
    expect(find.text('Submit for review'), findsNothing);
  });

  testWidgets('company catalog avoids excluded commercial terminology', (
    WidgetTester tester,
  ) async {
    await _pumpCompanyCatalog(
      tester,
      repository: _FakeCompanyCatalogRepository(
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

Future<void> _pumpCompanyCatalog(
  WidgetTester tester, {
  required _FakeCompanyCatalogRepository repository,
  bool includeDraftProviders = false,
}) async {
  final List<Override> overrides = <Override>[
    catalogAccessStateProvider.overrideWithValue(
      const AsyncData<CatalogAccessState>(
        CatalogAccessState(
          CatalogAudience.companyWorkflow,
          companyDraftManagementAllowed: true,
        ),
      ),
    ),
    companyCatalogRepositoryProvider.overrideWithValue(repository),
    catalogDrugClassesProvider.overrideWithValue(
      AsyncData<List<DrugClass>>(<DrugClass>[_drugClass()]),
    ),
    catalogGenericDrugsProvider.overrideWithValue(
      const AsyncData<List<GenericDrug>>(<GenericDrug>[]),
    ),
    catalogSpecialtiesProvider.overrideWithValue(
      const AsyncData<List<ProductSpecialty>>(<ProductSpecialty>[]),
    ),
  ];
  if (includeDraftProviders) {
    overrides.add(
      currentCatalogCompanyAccessProvider.overrideWithValue(
        const AsyncData<CatalogCompanyAccess>(
          CatalogCompanyAccess(
            companyId: 'company-id',
            companyName: 'Pharamty Demo Company',
            companyStatus: CompanyStatus.verified,
            membershipId: 'membership-id',
            companyRole: CompanyRole.companyAdmin,
            isMembershipActive: true,
            profileStatus: ProfileStatus.active,
          ),
        ),
      ),
    );
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: PharmaConnectTheme.dark(),
        home: const MobileCompanyCatalogEntryPage(),
      ),
    ),
  );
  await tester.pump();
}

DrugClass _drugClass() => DrugClass(
  id: 'respiratory-id',
  code: 'respiratory',
  isActive: true,
  translations: const LocalizedContent<TaxonomyTranslation>(
    english: TaxonomyTranslation(
      locale: ContentLocale.english,
      name: 'Respiratory',
    ),
  ),
);

ProductSummary _productSummary({
  String id = 'product-id',
  String brandName = 'Airvento 100 mcg',
  ProductLifecycleStatus status = ProductLifecycleStatus.draft,
}) {
  final ProductDetail detail = _productDetail(
    id: id,
    brandName: brandName,
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
  String brandName = 'Airvento 100 mcg',
  ProductLifecycleStatus status = ProductLifecycleStatus.draft,
}) {
  final DateTime timestamp = DateTime.utc(2026, 7, 1);
  final DrugClass drugClass = _drugClass();
  return ProductDetail(
    id: id,
    company: const CatalogCompanySummary(
      id: 'company-id',
      companyName: 'Pharamty Demo Company',
      legalName: 'Pharamty Demo Company LLC',
      countryId: 'iq',
      status: CompanyStatus.verified,
    ),
    genericDrug: null,
    drugClass: drugClass,
    category: ProductCategory.dietarySupplement,
    status: status,
    lifecycle: ProductLifecycleMetadata(
      submittedAt: status == ProductLifecycleStatus.submitted
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
    markets: const <ProductMarket>[],
    media: const <ProductMediaMetadata>[],
    brochures: const <ProductBrochureMetadata>[],
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

final class _FakeCompanyCatalogRepository implements CompanyCatalogRepository {
  _FakeCompanyCatalogRepository({
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
  Future<List<ProductSummary>> listOwnProducts({
    ProductLifecycleStatus? status,
  }) async {
    if (listCompleter case final Completer<List<ProductSummary>> value) {
      return value.future;
    }
    if (listError case final Object value) {
      throw value;
    }
    return products;
  }

  @override
  Future<ProductDetail> getOwnProductDetail(String productId) async {
    return detail ?? _productDetail(id: productId);
  }

  @override
  Future<CatalogReadinessResult> getSubmissionReadiness(
    String productId,
  ) async {
    return CatalogReadinessResult.ready(CatalogReadinessStage.submission);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
