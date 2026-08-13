import '../access/catalog_company_access.dart';
import '../access/healthcare_professional_eligibility_summary.dart';
import '../catalog_enums.dart';
import '../product/product_detail.dart';
import '../product/product_summary.dart';
import '../readiness/catalog_readiness_result.dart';
import '../taxonomy/active_ingredient.dart';
import '../taxonomy/drug_class.dart';
import '../taxonomy/generic_drug.dart';
import '../taxonomy/product_specialty.dart';
import 'catalog_commands.dart';

abstract interface class CatalogAccessRepository {
  Future<HealthcareProfessionalEligibilitySummary?>
  getHealthcareProfessionalEligibility();

  Future<CatalogCompanyAccess?> getCurrentCompanyAccess();
}

abstract interface class OfficialCatalogRepository {
  Future<List<ProductSummary>> listOfficialProducts(ProductListRequest request);

  Future<ProductDetail> getOfficialProductDetail(String productId);

  Future<List<DrugClass>> listVisibleDrugClasses();

  Future<GenericDrug> getVisibleGenericDrug(String genericDrugId);
}

abstract interface class CompanyCatalogRepository {
  Future<List<ProductSummary>> listOwnProducts({
    ProductLifecycleStatus? status,
  });

  Future<ProductDetail> getOwnProductDetail(String productId);

  Future<CatalogReadinessResult> getSubmissionReadiness(String productId);

  Future<CatalogReadinessResult> getPublicationReadiness(String productId);

  Future<ProductDetail> createDraft(CreateProductDraftCommand command);

  Future<ProductDetail> updateDraft(UpdateProductDraftCommand command);

  Future<ProductDetail> upsertTranslation({
    required String productId,
    required ContentLocale locale,
    required String brandName,
  });

  Future<ProductDetail> upsertIraqMarket(ProductMarketCommand command);

  Future<ProductDetail> upsertMarketTranslation(
    ProductMarketTranslationCommand command,
  );

  Future<ProductDetail> setSpecialties(
    String productId,
    List<String> specialtyIds,
  );

  Future<ProductDetail> upsertKeywordAlias({
    required String productId,
    required String locale,
    required String keyword,
    required String keywordType,
  });

  Future<ProductDetail> upsertMediaMetadata(
    ProductMediaMetadataCommand command,
  );

  Future<ProductDetail> upsertBrochureMetadata(
    ProductBrochureMetadataCommand command,
  );

  Future<ProductDetail> uploadProductMedia({
    required String productId,
    required ProductMediaType type,
    required CatalogUploadFile file,
  });

  Future<ProductDetail> uploadBrochure({
    required String productId,
    required ContentLocale locale,
    required String title,
    required CatalogUploadFile file,
  });

  Future<ProductDetail> submitForReview(String productId);

  Future<ProductDetail> withdrawSubmission(String productId);

  Future<ProductDetail> archiveOwnProduct(String productId, String reason);
}

abstract interface class AdminCatalogRepository {
  Future<List<ProductSummary>> listProductsByStatus(
    ProductLifecycleStatus status,
  );

  Future<ProductDetail> getProductDetail(String productId);

  Future<ProductDetail> requestChanges(String productId, String reason);

  Future<ProductDetail> publish(String productId);

  Future<ProductDetail> hide(String productId, String reason);

  Future<ProductDetail> restoreToPublished(String productId);

  Future<ProductDetail> restoreForChanges(String productId, String reason);

  Future<ProductDetail> archive(String productId, String reason);
}

abstract interface class CatalogTaxonomyRepository {
  Future<List<DrugClass>> listDrugClasses();

  Future<List<ActiveIngredient>> listActiveIngredients();

  Future<List<GenericDrug>> listGenericDrugs();

  Future<GenericDrug> getGenericDrug(String id);

  Future<List<ProductSpecialty>> listSpecialties();
}

abstract interface class AdminCatalogTaxonomyRepository {
  Future<ProductSpecialty> createSpecialty(
    String code,
    ProfessionType? professionType,
  );

  Future<ProductSpecialty> updateSpecialty(
    String id,
    String code,
    ProfessionType? professionType,
  );

  Future<ProductSpecialty> setSpecialtyActive(String id, bool isActive);

  Future<void> upsertSpecialtyTranslation({
    required String id,
    required ContentLocale locale,
    required String name,
    String? description,
  });

  Future<DrugClass> createDrugClass(String code, String? parentId);

  Future<DrugClass> updateDrugClass(String id, String code, String? parentId);

  Future<DrugClass> setDrugClassActive(String id, bool isActive);

  Future<void> upsertDrugClassTranslation({
    required String id,
    required ContentLocale locale,
    required String name,
    String? description,
  });

  Future<ActiveIngredient> createActiveIngredient(String code);

  Future<ActiveIngredient> updateActiveIngredient(String id, String code);

  Future<ActiveIngredient> setActiveIngredientActive(String id, bool isActive);

  Future<void> upsertActiveIngredientTranslation({
    required String id,
    required ContentLocale locale,
    required String name,
    String? description,
  });

  Future<GenericDrug> createGenericDrug(String code, String drugClassId);

  Future<GenericDrug> updateGenericDrug(
    String id,
    String code,
    String drugClassId,
  );

  Future<void> upsertGenericDrugTranslation({
    required String id,
    required ContentLocale locale,
    required String name,
    String? description,
  });

  Future<void> setGenericDrugIngredients(String id, List<String> ingredientIds);

  Future<GenericDrug> setGenericDrugActive(String id, bool isActive);
}
