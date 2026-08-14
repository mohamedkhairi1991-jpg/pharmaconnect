import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/catalog_enums.dart';
import '../domain/product/catalog_media_access_request.dart';
import '../domain/product/product_detail.dart';
import '../domain/product/product_summary.dart';
import '../domain/readiness/catalog_readiness_result.dart';
import '../domain/repository/catalog_commands.dart';
import '../domain/taxonomy/active_ingredient.dart';
import '../domain/taxonomy/drug_class.dart';
import '../domain/taxonomy/generic_drug.dart';
import '../domain/taxonomy/product_specialty.dart';
import 'catalog_access_providers.dart';
import 'catalog_provider_guards.dart';
import 'catalog_repository_providers.dart';

final officialProductListProvider =
    FutureProvider.family<List<ProductSummary>, ProductListRequest>((
      Ref ref,
      ProductListRequest request,
    ) async {
      requireOfficialCatalogAccess(
        await ref.watch(catalogAccessStateProvider.future),
      );
      return ref
          .watch(officialCatalogRepositoryProvider)
          .listOfficialProducts(request);
    });

final officialProductDetailProvider =
    FutureProvider.family<ProductDetail, String>((
      Ref ref,
      String productId,
    ) async {
      requireOfficialCatalogAccess(
        await ref.watch(catalogAccessStateProvider.future),
      );
      return ref
          .watch(officialCatalogRepositoryProvider)
          .getOfficialProductDetail(productId);
    });

final visibleDrugClassesProvider = FutureProvider<List<DrugClass>>((
  Ref ref,
) async {
  requireOfficialCatalogAccess(
    await ref.watch(catalogAccessStateProvider.future),
  );
  return ref.watch(officialCatalogRepositoryProvider).listVisibleDrugClasses();
});

final visibleGenericDrugProvider = FutureProvider.family<GenericDrug, String>((
  Ref ref,
  String genericDrugId,
) async {
  requireOfficialCatalogAccess(
    await ref.watch(catalogAccessStateProvider.future),
  );
  return ref
      .watch(officialCatalogRepositoryProvider)
      .getVisibleGenericDrug(genericDrugId);
});

final companyProductListProvider =
    FutureProvider.family<List<ProductSummary>, ProductLifecycleStatus?>((
      Ref ref,
      ProductLifecycleStatus? status,
    ) async {
      requireCompanyWorkflowAccess(
        await ref.watch(catalogAccessStateProvider.future),
      );
      return ref
          .watch(companyCatalogRepositoryProvider)
          .listOwnProducts(status: status);
    });

final companyProductDetailProvider =
    FutureProvider.family<ProductDetail, String>((
      Ref ref,
      String productId,
    ) async {
      requireCompanyWorkflowAccess(
        await ref.watch(catalogAccessStateProvider.future),
      );
      return ref
          .watch(companyCatalogRepositoryProvider)
          .getOwnProductDetail(productId);
    });

final companyProductReadinessProvider =
    FutureProvider.family<
      CatalogReadinessResult,
      CompanyProductReadinessRequest
    >((Ref ref, CompanyProductReadinessRequest request) async {
      requireCompanyWorkflowAccess(
        await ref.watch(catalogAccessStateProvider.future),
      );
      final repository = ref.watch(companyCatalogRepositoryProvider);
      return switch (request.stage) {
        CatalogReadinessStage.submission => repository.getSubmissionReadiness(
          request.productId,
        ),
        CatalogReadinessStage.publication => repository.getPublicationReadiness(
          request.productId,
        ),
      };
    });

final adminReviewQueueProvider =
    FutureProvider.family<List<ProductSummary>, ProductLifecycleStatus>((
      Ref ref,
      ProductLifecycleStatus status,
    ) async {
      requireAdministratorAccess(
        await ref.watch(catalogAccessStateProvider.future),
      );
      return ref
          .watch(adminCatalogRepositoryProvider)
          .listProductsByStatus(status);
    });

final adminProductDetailProvider = FutureProvider.family<ProductDetail, String>(
  (Ref ref, String productId) async {
    requireAdministratorAccess(
      await ref.watch(catalogAccessStateProvider.future),
    );
    return ref
        .watch(adminCatalogRepositoryProvider)
        .getProductDetail(productId);
  },
);

final adminCatalogMediaUrlProvider = FutureProvider.autoDispose
    .family<Uri, CatalogMediaAccessRequest>((
      Ref ref,
      CatalogMediaAccessRequest request,
    ) async {
      requireAdministratorAccess(
        await ref.watch(catalogAccessStateProvider.future),
      );
      return ref
          .watch(adminCatalogRepositoryProvider)
          .createMediaReviewUrl(request);
    });

final catalogDrugClassesProvider = FutureProvider<List<DrugClass>>((
  Ref ref,
) async {
  requireTaxonomyAccess(await ref.watch(catalogAccessStateProvider.future));
  return ref.watch(catalogTaxonomyRepositoryProvider).listDrugClasses();
});

final catalogActiveIngredientsProvider = FutureProvider<List<ActiveIngredient>>(
  (Ref ref) async {
    requireTaxonomyAccess(await ref.watch(catalogAccessStateProvider.future));
    return ref.watch(catalogTaxonomyRepositoryProvider).listActiveIngredients();
  },
);

final catalogGenericDrugsProvider = FutureProvider<List<GenericDrug>>((
  Ref ref,
) async {
  requireTaxonomyAccess(await ref.watch(catalogAccessStateProvider.future));
  return ref.watch(catalogTaxonomyRepositoryProvider).listGenericDrugs();
});

final catalogGenericDrugProvider = FutureProvider.family<GenericDrug, String>((
  Ref ref,
  String genericDrugId,
) async {
  requireTaxonomyAccess(await ref.watch(catalogAccessStateProvider.future));
  return ref
      .watch(catalogTaxonomyRepositoryProvider)
      .getGenericDrug(genericDrugId);
});

final catalogSpecialtiesProvider = FutureProvider<List<ProductSpecialty>>((
  Ref ref,
) async {
  requireTaxonomyAccess(await ref.watch(catalogAccessStateProvider.future));
  return ref.watch(catalogTaxonomyRepositoryProvider).listSpecialties();
});

final class CompanyProductReadinessRequest {
  const CompanyProductReadinessRequest({
    required this.productId,
    required this.stage,
  });

  final String productId;
  final CatalogReadinessStage stage;

  @override
  bool operator ==(Object other) =>
      other is CompanyProductReadinessRequest &&
      other.productId == productId &&
      other.stage == stage;

  @override
  int get hashCode => Object.hash(productId, stage);
}
