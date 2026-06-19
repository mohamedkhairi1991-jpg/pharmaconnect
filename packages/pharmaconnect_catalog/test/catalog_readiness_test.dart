import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';

void main() {
  test('readiness is true only when no advisory issues exist', () {
    final CatalogReadinessResult ready = CatalogReadinessResult.ready(
      CatalogReadinessStage.submission,
    );
    final CatalogReadinessResult blocked = CatalogReadinessResult(
      stage: CatalogReadinessStage.publication,
      issues: const <CatalogReadinessIssue>{
        CatalogReadinessIssue.notMarketedInIraq,
        CatalogReadinessIssue.englishIraqContentMissing,
      },
    );

    expect(ready.isReady, isTrue);
    expect(blocked.isReady, isFalse);
    expect(blocked.issues, contains(CatalogReadinessIssue.notMarketedInIraq));
  });

  test('readiness issues are deduplicated and immutable', () {
    final CatalogReadinessResult result = CatalogReadinessResult(
      stage: CatalogReadinessStage.submission,
      issues: const <CatalogReadinessIssue>[
        CatalogReadinessIssue.activeSpecialtyMissing,
        CatalogReadinessIssue.activeSpecialtyMissing,
      ],
    );

    expect(result.issues, hasLength(1));
    expect(
      () => result.issues.add(CatalogReadinessIssue.iraqMarketMissing),
      throwsUnsupportedError,
    );
  });

  test('media and brochures are not readiness issue types', () {
    final Set<String> issueValues = CatalogReadinessIssue.values
        .map((CatalogReadinessIssue issue) => issue.databaseValue)
        .toSet();

    expect(issueValues, isNot(contains('product_image_missing')));
    expect(issueValues, isNot(contains('package_image_missing')));
    expect(issueValues, isNot(contains('brochure_missing')));
  });
}
