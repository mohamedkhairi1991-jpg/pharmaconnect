import '../catalog_enums.dart';

final class CatalogReadinessResult {
  CatalogReadinessResult({
    required this.stage,
    required Iterable<CatalogReadinessIssue> issues,
  }) : issues = Set<CatalogReadinessIssue>.unmodifiable(issues);

  factory CatalogReadinessResult.ready(CatalogReadinessStage stage) {
    return CatalogReadinessResult(
      stage: stage,
      issues: const <CatalogReadinessIssue>{},
    );
  }

  final CatalogReadinessStage stage;
  final Set<CatalogReadinessIssue> issues;

  bool get isReady => issues.isEmpty;
}
