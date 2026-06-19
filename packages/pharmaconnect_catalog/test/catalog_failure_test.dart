import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';

void main() {
  test('catalog failure preserves stable kind and diagnostics', () {
    const CatalogFailure failure = CatalogFailure(
      kind: CatalogFailureKind.unauthorized,
      diagnosticCode: 'rls_denied',
    );

    expect(failure.kind, CatalogFailureKind.unauthorized);
    expect(failure.diagnosticCode, 'rls_denied');
    expect(failure.toString(), contains('rls_denied'));
  });

  test('incompatible data constructor does not expose a default value', () {
    const CatalogFailure failure = CatalogFailure.incompatibleData(
      diagnosticCode: 'unknown_product_status',
    );

    expect(failure.kind, CatalogFailureKind.incompatibleData);
    expect(failure.cause, isNull);
  });
}
