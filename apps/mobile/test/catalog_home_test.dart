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
    expect(find.text('100 mcg • inhaler'), findsOneWidget);
  });

  testWidgets('product cards avoid supply-chain and commerce wording', (
    WidgetTester tester,
  ) async {
    await _pumpCatalogHome(
      tester,
      repository: _FakeOfficialCatalogRepository(
        products: <ProductSummary>[_productSummary()],
      ),
    );
    await tester.pumpAndSettle();

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

ProductSummary _productSummary() {
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

  return ProductSummary(
    id: 'product-id',
    company: const CatalogCompanySummary(
      id: 'company-id',
      companyName: 'PharmaConnect Labs',
      legalName: 'PharmaConnect Labs LLC',
      countryId: 'iq',
      status: CompanyStatus.verified,
    ),
    genericDrug: GenericDrug(
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
      composition: const <GenericCompositionEntry>[],
    ),
    drugClass: drugClass,
    category: ProductCategory.prescriptionDrug,
    status: ProductLifecycleStatus.published,
    translations: LocalizedContent<ProductTranslation>(
      english: ProductTranslation(
        id: 'translation-id',
        locale: ContentLocale.english,
        brandName: 'AeroCure',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ),
    iraqMarket: ProductMarket(
      id: 'market-id',
      countryId: 'iq',
      strength: '100 mcg',
      dosageForm: 'inhaler',
      route: 'inhalation',
      packSize: '1 inhaler',
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
