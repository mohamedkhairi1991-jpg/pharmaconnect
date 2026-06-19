import '../catalog_enums.dart';
import '../product/product_detail.dart';
import 'catalog_readiness_result.dart';

abstract final class CatalogReadinessEvaluator {
  static CatalogReadinessResult evaluate(
    ProductDetail product,
    CatalogReadinessStage stage,
  ) {
    final Set<CatalogReadinessIssue> issues = <CatalogReadinessIssue>{};

    if (product.company.status != CompanyStatus.verified) {
      issues.add(CatalogReadinessIssue.companyNotVerified);
    }
    if (!product.drugClass.isActive) {
      issues.add(CatalogReadinessIssue.drugClassNotActive);
    }
    if (product.category != ProductCategory.dietarySupplement) {
      if (product.genericDrug == null || !product.genericDrug!.isActive) {
        issues.add(CatalogReadinessIssue.genericDrugNotActive);
      } else if (product.genericDrug!.composition.isEmpty) {
        issues.add(CatalogReadinessIssue.genericCompositionInvalid);
      }
    }
    if (!product.translations.hasRequiredEnglish) {
      issues.add(CatalogReadinessIssue.englishProductTranslationMissing);
    }
    final market = product.iraqMarket;
    if (market == null) {
      issues.add(CatalogReadinessIssue.iraqMarketMissing);
    } else {
      if (!market.translations.hasRequiredEnglish) {
        issues.add(CatalogReadinessIssue.englishIraqContentMissing);
      }
      if (stage == CatalogReadinessStage.publication &&
          market.marketStatus != IraqMarketStatus.marketedInIraq) {
        issues.add(CatalogReadinessIssue.notMarketedInIraq);
      }
    }
    if (product.specialties.where((value) => value.isActive).isEmpty) {
      issues.add(CatalogReadinessIssue.activeSpecialtyMissing);
    }
    if (product.presentationFingerprint == null) {
      issues.add(CatalogReadinessIssue.presentationFingerprintMissing);
    }

    return CatalogReadinessResult(stage: stage, issues: issues);
  }
}
