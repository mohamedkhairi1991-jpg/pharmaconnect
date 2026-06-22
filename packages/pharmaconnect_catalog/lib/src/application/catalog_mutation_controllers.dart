import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/catalog_enums.dart';
import '../domain/product/product_detail.dart';
import '../domain/repository/catalog_commands.dart';
import 'catalog_access_providers.dart';
import 'catalog_provider_guards.dart';
import 'catalog_read_providers.dart';
import 'catalog_repository_providers.dart';

final companyCatalogMutationController =
    AsyncNotifierProvider<CompanyCatalogMutationController, ProductDetail?>(
      CompanyCatalogMutationController.new,
    );

final adminCatalogLifecycleController =
    AsyncNotifierProvider<AdminCatalogLifecycleController, ProductDetail?>(
      AdminCatalogLifecycleController.new,
    );

final class CompanyCatalogMutationController
    extends AsyncNotifier<ProductDetail?> {
  @override
  Future<ProductDetail?> build() async {
    await ref.watch(catalogAccessStateProvider.future);
    return null;
  }

  Future<ProductDetail> createDraft(CreateProductDraftCommand command) =>
      _mutate(
        () => ref.read(companyCatalogRepositoryProvider).createDraft(command),
      );

  Future<ProductDetail> updateDraft(UpdateProductDraftCommand command) =>
      _mutate(
        () => ref.read(companyCatalogRepositoryProvider).updateDraft(command),
        productId: command.productId,
      );

  Future<ProductDetail> upsertTranslation({
    required String productId,
    required ContentLocale locale,
    required String brandName,
  }) => _mutate(
    () => ref
        .read(companyCatalogRepositoryProvider)
        .upsertTranslation(
          productId: productId,
          locale: locale,
          brandName: brandName,
        ),
    productId: productId,
  );

  Future<ProductDetail> upsertIraqMarket(ProductMarketCommand command) =>
      _mutate(
        () => ref
            .read(companyCatalogRepositoryProvider)
            .upsertIraqMarket(command),
        productId: command.productId,
      );

  Future<ProductDetail> upsertMarketTranslation(
    ProductMarketTranslationCommand command,
  ) => _mutate(
    () => ref
        .read(companyCatalogRepositoryProvider)
        .upsertMarketTranslation(command),
    productId: command.productId,
  );

  Future<ProductDetail> setSpecialties(
    String productId,
    List<String> specialtyIds,
  ) => _mutate(
    () => ref
        .read(companyCatalogRepositoryProvider)
        .setSpecialties(productId, specialtyIds),
    productId: productId,
  );

  Future<ProductDetail> upsertKeywordAlias({
    required String productId,
    required String locale,
    required String keyword,
    required String keywordType,
  }) => _mutate(
    () => ref
        .read(companyCatalogRepositoryProvider)
        .upsertKeywordAlias(
          productId: productId,
          locale: locale,
          keyword: keyword,
          keywordType: keywordType,
        ),
    productId: productId,
  );

  Future<ProductDetail> upsertMediaMetadata(
    ProductMediaMetadataCommand command,
  ) => _mutate(
    () =>
        ref.read(companyCatalogRepositoryProvider).upsertMediaMetadata(command),
    productId: command.productId,
  );

  Future<ProductDetail> upsertBrochureMetadata(
    ProductBrochureMetadataCommand command,
  ) => _mutate(
    () => ref
        .read(companyCatalogRepositoryProvider)
        .upsertBrochureMetadata(command),
    productId: command.productId,
  );

  Future<ProductDetail> submitForReview(String productId) => _mutate(
    () => ref.read(companyCatalogRepositoryProvider).submitForReview(productId),
    productId: productId,
  );

  Future<ProductDetail> withdrawSubmission(String productId) => _mutate(
    () => ref
        .read(companyCatalogRepositoryProvider)
        .withdrawSubmission(productId),
    productId: productId,
  );

  Future<ProductDetail> archiveOwnProduct(String productId, String reason) =>
      _mutate(
        () => ref
            .read(companyCatalogRepositoryProvider)
            .archiveOwnProduct(productId, reason),
        productId: productId,
      );

  Future<ProductDetail> _mutate(
    Future<ProductDetail> Function() operation, {
    String? productId,
  }) async {
    state = const AsyncLoading<ProductDetail?>();
    final AsyncValue<ProductDetail?> result =
        await AsyncValue.guard<ProductDetail?>(() async {
          requireCompanyWorkflowAccess(
            await ref.read(catalogAccessStateProvider.future),
            requireDraftManagement: true,
          );
          final ProductDetail changed = await operation();
          final String id = productId ?? changed.id;
          _invalidateCompanyProduct(id);
          return ref.read(companyProductDetailProvider(id).future);
        });
    state = result;
    return result.requireValue!;
  }

  void _invalidateCompanyProduct(String productId) {
    ref.invalidate(companyProductListProvider);
    ref.invalidate(companyProductDetailProvider(productId));
    ref.invalidate(companyProductReadinessProvider);
  }
}

final class AdminCatalogLifecycleController
    extends AsyncNotifier<ProductDetail?> {
  @override
  Future<ProductDetail?> build() async {
    await ref.watch(catalogAccessStateProvider.future);
    return null;
  }

  Future<ProductDetail> requestChanges(String productId, String reason) =>
      _mutate(
        productId,
        () => ref
            .read(adminCatalogRepositoryProvider)
            .requestChanges(productId, reason),
      );

  Future<ProductDetail> publish(String productId) => _mutate(
    productId,
    () => ref.read(adminCatalogRepositoryProvider).publish(productId),
  );

  Future<ProductDetail> hide(String productId, String reason) => _mutate(
    productId,
    () => ref.read(adminCatalogRepositoryProvider).hide(productId, reason),
  );

  Future<ProductDetail> restoreToPublished(String productId) => _mutate(
    productId,
    () =>
        ref.read(adminCatalogRepositoryProvider).restoreToPublished(productId),
  );

  Future<ProductDetail> restoreForChanges(String productId, String reason) =>
      _mutate(
        productId,
        () => ref
            .read(adminCatalogRepositoryProvider)
            .restoreForChanges(productId, reason),
      );

  Future<ProductDetail> archive(String productId, String reason) => _mutate(
    productId,
    () => ref.read(adminCatalogRepositoryProvider).archive(productId, reason),
  );

  Future<ProductDetail> _mutate(
    String productId,
    Future<ProductDetail> Function() operation,
  ) async {
    state = const AsyncLoading<ProductDetail?>();
    final AsyncValue<ProductDetail?> result =
        await AsyncValue.guard<ProductDetail?>(() async {
          requireAdministratorAccess(
            await ref.read(catalogAccessStateProvider.future),
          );
          await operation();
          ref.invalidate(adminReviewQueueProvider);
          ref.invalidate(adminProductDetailProvider(productId));
          ref.invalidate(officialProductListProvider);
          ref.invalidate(officialProductDetailProvider(productId));
          return ref.read(adminProductDetailProvider(productId).future);
        });
    state = result;
    return result.requireValue!;
  }
}
