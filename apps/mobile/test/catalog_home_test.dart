import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_mobile/features/catalog/presentation/catalog_entry_pages.dart';

void main() {
  testWidgets('official catalog home shows loading state', (
    WidgetTester tester,
  ) async {
    await _pumpCatalogHome(
      tester,
      repository: _FakeOfficialCatalogRepository(
        completer: Completer<List<ProductSummary>>(),
      ),
    );

    expect(find.text('Loading official catalog'), findsOneWidget);
  });

  testWidgets('official catalog home shows empty state', (
    WidgetTester tester,
  ) async {
    await _pumpCatalogHome(
      tester,
      repository: _FakeOfficialCatalogRepository(products: const []),
    );
    await tester.pumpAndSettle();

    expect(find.text('No official products yet'), findsOneWidget);
    expect(
      find.text('Published catalog entries will appear here.'),
      findsOneWidget,
    );
  });

  testWidgets('official catalog home shows error state', (
    WidgetTester tester,
  ) async {
    await _pumpCatalogHome(
      tester,
      repository: _FakeOfficialCatalogRepository(error: Exception('boom')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Catalog information could not load'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('official catalog home shows provider-driven product data', (
    WidgetTester tester,
  ) async {
    await _pumpCatalogHome(
      tester,
      repository: _FakeOfficialCatalogRepository(
        products: <ProductSummary>[_productSummary()],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AeroCure'), findsOneWidget);
    expect(find.text('Salbutamol'), findsOneWidget);
    expect(find.text('PharmaConnect Labs'), findsOneWidget);
    expect(find.text('100 mcg / inhaler'), findsOneWidget);
  });

  testWidgets('data state renders multiple product cards', (
    WidgetTester tester,
  ) async {
    await _pumpCatalogHome(
      tester,
      repository: _FakeOfficialCatalogRepository(
        products: <ProductSummary>[_productSummary(), _cardioProductSummary()],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AeroCure'), findsOneWidget);
    expect(find.text('CardioZen'), findsOneWidget);
  });

  testWidgets('local search filters by brand name', (
    WidgetTester tester,
  ) async {
    await _pumpCatalogHomeWithSearchProducts(tester);

    await tester.enterText(find.byType(TextField), 'cardiozen');
    await tester.pumpAndSettle();

    expect(find.text('CardioZen'), findsOneWidget);
    expect(find.text('AeroCure'), findsNothing);
    expect(find.text('GlucoTrack'), findsNothing);
  });

  testWidgets('local search filters by generic name', (
    WidgetTester tester,
  ) async {
    await _pumpCatalogHomeWithSearchProducts(tester);

    await tester.enterText(find.byType(TextField), 'metformin');
    await tester.pumpAndSettle();

    expect(find.text('GlucoTrack'), findsOneWidget);
    expect(find.text('AeroCure'), findsNothing);
    expect(find.text('CardioZen'), findsNothing);
  });

  testWidgets('local search filters by company name', (
    WidgetTester tester,
  ) async {
    await _pumpCatalogHomeWithSearchProducts(tester);

    await tester.enterText(find.byType(TextField), 'heart labs');
    await tester.pumpAndSettle();

    expect(find.text('CardioZen'), findsOneWidget);
    expect(find.text('AeroCure'), findsNothing);
    expect(find.text('GlucoTrack'), findsNothing);
  });

  testWidgets('no-match search shows safe empty state', (
    WidgetTester tester,
  ) async {
    await _pumpCatalogHomeWithSearchProducts(tester);

    await tester.enterText(find.byType(TextField), 'not-a-product');
    await tester.pumpAndSettle();

    expect(find.text('No catalog matches found'), findsOneWidget);
    expect(find.text('AeroCure'), findsNothing);
    expect(find.text('CardioZen'), findsNothing);
    expect(find.text('GlucoTrack'), findsNothing);
  });

  testWidgets('clearing local search restores product cards', (
    WidgetTester tester,
  ) async {
    await _pumpCatalogHomeWithSearchProducts(tester);

    await tester.enterText(find.byType(TextField), 'metformin');
    await tester.pumpAndSettle();
    expect(find.text('GlucoTrack'), findsOneWidget);
    expect(find.text('AeroCure'), findsNothing);

    await tester.tap(find.byTooltip('Clear catalog search'));
    await tester.pumpAndSettle();

    expect(find.text('AeroCure'), findsOneWidget);
    expect(find.text('CardioZen'), findsOneWidget);
    expect(find.text('GlucoTrack'), findsOneWidget);
  });

  testWidgets('product cards avoid supply-chain and commerce wording', (
    WidgetTester tester,
  ) async {
    await _pumpCatalogHomeWithSearchProducts(tester);

    final RegExp prohibitedWords = RegExp(
      r'\b(stock|price|order|orders|seller|pharmacy|pharmacies|availability|available)\b',
      caseSensitive: false,
    );
    final Iterable<Text> visibleText = tester.widgetList<Text>(
      find.byType(Text),
    );

    final String textSnapshot = visibleText
        .map((Text text) => text.data ?? '')
        .join('\n');

    expect(prohibitedWords.hasMatch(textSnapshot), isFalse);
  });
}

Future<void> _pumpCatalogHome(
  WidgetTester tester, {
  required _FakeOfficialCatalogRepository repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        catalogAccessStateProvider.overrideWithValue(
          const AsyncData<CatalogAccessState>(
            CatalogAccessState(CatalogAudience.officialCatalog),
          ),
        ),
        officialCatalogRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: MobileOfficialCatalogEntryPage()),
    ),
  );
  await tester.pump();
}

Future<void> _pumpCatalogHomeWithSearchProducts(WidgetTester tester) async {
  await _pumpCatalogHome(
    tester,
    repository: _FakeOfficialCatalogRepository(
      products: <ProductSummary>[
        _productSummary(),
        _cardioProductSummary(),
        _diabetesProductSummary(),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

ProductSummary _productSummary({
  String id = 'product-id',
  String brandName = 'AeroCure',
  String genericName = 'Salbutamol',
  String companyName = 'PharmaConnect Labs',
  String strength = '100 mcg',
  String dosageForm = 'inhaler',
}) {
  final DateTime timestamp = DateTime.utc(2026, 6, 1);
  final DrugClass drugClass = DrugClass(
    id: '$id-class',
    code: '$id-class',
    isActive: true,
    translations: LocalizedContent<TaxonomyTranslation>(
      english: TaxonomyTranslation(
        locale: ContentLocale.english,
        name: 'Respiratory',
      ),
    ),
  );

  return ProductSummary(
    id: id,
    company: CatalogCompanySummary(
      id: '$id-company',
      companyName: companyName,
      legalName: '$companyName LLC',
      countryId: 'iq',
      status: CompanyStatus.verified,
    ),
    genericDrug: GenericDrug(
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
    ),
    drugClass: drugClass,
    category: ProductCategory.prescriptionDrug,
    status: ProductLifecycleStatus.published,
    translations: LocalizedContent<ProductTranslation>(
      english: ProductTranslation(
        id: '$id-translation',
        locale: ContentLocale.english,
        brandName: brandName,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ),
    iraqMarket: ProductMarket(
      id: '$id-market',
      countryId: 'iq',
      strength: strength,
      dosageForm: dosageForm,
      route: 'inhalation',
      packSize: '1 unit',
      marketStatus: IraqMarketStatus.marketedInIraq,
      registrationStatus: ProductRegistrationStatus.registered,
      translations: const LocalizedContent<ProductMarketTranslation>(
        english: null,
      ),
      createdAt: timestamp,
      updatedAt: timestamp,
    ),
    updatedAt: timestamp,
  );
}

ProductSummary _cardioProductSummary() => _productSummary(
  id: 'cardio-product-id',
  brandName: 'CardioZen',
  genericName: 'Atorvastatin',
  companyName: 'Heart Labs',
  strength: '20 mg',
  dosageForm: 'tablet',
);

ProductSummary _diabetesProductSummary() => _productSummary(
  id: 'diabetes-product-id',
  brandName: 'GlucoTrack',
  genericName: 'Metformin',
  companyName: 'Metabolic Care',
  strength: '500 mg',
  dosageForm: 'tablet',
);

final class _FakeOfficialCatalogRepository
    implements OfficialCatalogRepository {
  _FakeOfficialCatalogRepository({
    this.products = const <ProductSummary>[],
    this.error,
    this.completer,
  });

  final List<ProductSummary> products;
  final Object? error;
  final Completer<List<ProductSummary>>? completer;

  @override
  Future<List<ProductSummary>> listOfficialProducts(
    ProductListRequest request,
  ) async {
    if (completer case final Completer<List<ProductSummary>> value) {
      return value.future;
    }
    if (error case final Object value) {
      throw value;
    }
    return products;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
