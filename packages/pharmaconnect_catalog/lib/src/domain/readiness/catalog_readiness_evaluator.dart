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
    final String? englishBrandName = product.translations.english?.brandName;
    if (englishBrandName == null || englishBrandName.trim().isEmpty) {
      issues.add(CatalogReadinessIssue.englishProductTranslationMissing);
    }
    final market = product.iraqMarket;
    if (market == null) {
      issues.add(CatalogReadinessIssue.iraqMarketMissing);
    } else {
      final marketTranslation = market.translations.english;
      if (marketTranslation == null ||
          marketTranslation.storageConditions.trim().isEmpty ||
          marketTranslation.approvedIndications.trim().isEmpty ||
          marketTranslation.usualAdultDose.trim().isEmpty ||
          marketTranslation.contraindications.trim().isEmpty ||
          marketTranslation.commonAdverseEffects.trim().isEmpty) {
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
