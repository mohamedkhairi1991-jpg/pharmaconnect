import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

import 'support/catalog_fixtures.dart';

void main() {
  group('repository providers', () {
    test('all repositories are overridable', () {
      final _FakeCatalogAccessRepository access =
          _FakeCatalogAccessRepository();
      final _FakeOfficialCatalogRepository official =
          _FakeOfficialCatalogRepository();
      final _FakeCompanyCatalogRepository company =
          _FakeCompanyCatalogRepository();
      final _FakeAdminCatalogRepository admin = _FakeAdminCatalogRepository();
      final _FakeCatalogTaxonomyRepository taxonomy =
          _FakeCatalogTaxonomyRepository();
      final _FakeAdminCatalogTaxonomyRepository adminTaxonomy =
          _FakeAdminCatalogTaxonomyRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          catalogAccessRepositoryProvider.overrideWithValue(access),
          officialCatalogRepositoryProvider.overrideWithValue(official),
          companyCatalogRepositoryProvider.overrideWithValue(company),
          adminCatalogRepositoryProvider.overrideWithValue(admin),
          catalogTaxonomyRepositoryProvider.overrideWithValue(taxonomy),
          adminCatalogTaxonomyRepositoryProvider.overrideWithValue(
            adminTaxonomy,
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(catalogAccessRepositoryProvider), same(access));
      expect(container.read(officialCatalogRepositoryProvider), same(official));
      expect(container.read(companyCatalogRepositoryProvider), same(company));
      expect(container.read(adminCatalogRepositoryProvider), same(admin));
      expect(container.read(catalogTaxonomyRepositoryProvider), same(taxonomy));
      expect(
        container.read(adminCatalogTaxonomyRepositoryProvider),
        same(adminTaxonomy),
      );
    });
  });

  group('session-aware access', () {
    test('signed-out access fails closed', () async {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          sessionPrincipalProvider.overrideWithValue(
            const AsyncData<SessionPrincipal?>(null),
          ),
        ],
      );
      addTearDown(container.dispose);

      final CatalogAccessState access = await container.read(
        catalogAccessStateProvider.future,
      );

      expect(access.audience, CatalogAudience.signedOut);
      final AsyncValue<List<ProductSummary>> result = await _waitForError(
        container,
        officialProductListProvider(const ProductListRequest()),
      );

      expect(
        result.error,
        isA<CatalogFailure>().having(
          (CatalogFailure failure) => failure.kind,
          'kind',
          CatalogFailureKind.unauthenticated,
        ),
      );
    });

    test('approved physician can call official catalog providers', () async {
      final _FakeCatalogAccessRepository access = _FakeCatalogAccessRepository()
        ..eligibility = _eligibility(ProfessionType.physician);
      final _FakeOfficialCatalogRepository official =
          _FakeOfficialCatalogRepository()
            ..products = <ProductSummary>[_summary()];
      final ProviderContainer container = ProviderContainer(
        overrides: [
          sessionPrincipalProvider.overrideWithValue(
            AsyncData<SessionPrincipal?>(
              _principal(PlatformRole.healthcareProfessional),
            ),
          ),
          catalogAccessRepositoryProvider.overrideWithValue(access),
          officialCatalogRepositoryProvider.overrideWithValue(official),
        ],
      );
      addTearDown(container.dispose);

      final List<ProductSummary> products = await container.read(
        officialProductListProvider(const ProductListRequest()).future,
      );

      expect(products, hasLength(1));
      expect(official.listCalls, 1);
    });

    test('pharmacist access is denied before repository calls', () async {
      final _FakeCatalogAccessRepository access = _FakeCatalogAccessRepository()
        ..eligibility = _eligibility(ProfessionType.pharmacist);
      final _FakeOfficialCatalogRepository official =
          _FakeOfficialCatalogRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          sessionPrincipalProvider.overrideWithValue(
            AsyncData<SessionPrincipal?>(
              _principal(PlatformRole.healthcareProfessional),
            ),
          ),
          catalogAccessRepositoryProvider.overrideWithValue(access),
          officialCatalogRepositoryProvider.overrideWithValue(official),
        ],
      );
      addTearDown(container.dispose);

      final AsyncValue<List<ProductSummary>> result = await _waitForError(
        container,
        officialProductListProvider(const ProductListRequest()),
      );

      expect(
        result.error,
        isA<CatalogFailure>().having(
          (CatalogFailure failure) => failure.kind,
          'kind',
          CatalogFailureKind.unauthorized,
        ),
      );
      expect(official.listCalls, 0);
    });

    test('company capabilities follow membership role', () async {
      final _FakeCatalogAccessRepository access = _FakeCatalogAccessRepository()
        ..companyAccess = _companyAccess(CompanyRole.marketingManager);
      final ProviderContainer container = ProviderContainer(
        overrides: [
          sessionPrincipalProvider.overrideWithValue(
            AsyncData<SessionPrincipal?>(_principal(PlatformRole.companyUser)),
          ),
          catalogAccessRepositoryProvider.overrideWithValue(access),
        ],
      );
      addTearDown(container.dispose);

      final CatalogAccessState state = await container.read(
        catalogAccessStateProvider.future,
      );

      expect(state.canReadCompanyWorkflow, isTrue);
      expect(state.canManageCompanyDrafts, isFalse);
    });

    test('suspended company access fails closed', () async {
      final _FakeCatalogAccessRepository access = _FakeCatalogAccessRepository()
        ..companyAccess = _companyAccess(
          CompanyRole.companyAdmin,
          companyStatus: CompanyStatus.suspended,
        );
      final _FakeCompanyCatalogRepository company =
          _FakeCompanyCatalogRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          sessionPrincipalProvider.overrideWithValue(
            AsyncData<SessionPrincipal?>(_principal(PlatformRole.companyUser)),
          ),
          catalogAccessRepositoryProvider.overrideWithValue(access),
          companyCatalogRepositoryProvider.overrideWithValue(company),
        ],
      );
      addTearDown(container.dispose);

      final AsyncValue<List<ProductSummary>> result = await _waitForError(
        container,
        companyProductListProvider(null),
      );

      expect(result.error, isA<CatalogFailure>());
      expect(company.listCalls, 0);
    });

    test('session user change does not expose previous catalog data', () async {
      final _FakeCatalogAccessRepository physicianAccess =
          _FakeCatalogAccessRepository()
            ..eligibility = _eligibility(ProfessionType.physician);
      final _FakeCatalogAccessRepository pharmacistAccess =
          _FakeCatalogAccessRepository()
            ..eligibility = _eligibility(ProfessionType.pharmacist);
      final _FakeOfficialCatalogRepository official =
          _FakeOfficialCatalogRepository()
            ..products = <ProductSummary>[_summary()];
      final ProviderContainer container = ProviderContainer(
        overrides: [
          sessionPrincipalProvider.overrideWithValue(
            AsyncData<SessionPrincipal?>(
              _principal(
                PlatformRole.healthcareProfessional,
                authUserId: 'physician-user',
              ),
            ),
          ),
          catalogAccessRepositoryProvider.overrideWithValue(physicianAccess),
          officialCatalogRepositoryProvider.overrideWithValue(official),
        ],
      );
      addTearDown(container.dispose);
      final provider = officialProductListProvider(const ProductListRequest());

      expect(await container.read(provider.future), hasLength(1));

      container.updateOverrides([
        sessionPrincipalProvider.overrideWithValue(
          AsyncData<SessionPrincipal?>(
            _principal(
              PlatformRole.healthcareProfessional,
              authUserId: 'pharmacist-user',
            ),
          ),
        ),
        catalogAccessRepositoryProvider.overrideWithValue(pharmacistAccess),
        officialCatalogRepositoryProvider.overrideWithValue(official),
      ]);
      container.invalidate(provider);

      final AsyncValue<List<ProductSummary>> result = await _waitForError(
        container,
        provider,
      );

      expect(
        result.error,
        isA<CatalogFailure>().having(
          (CatalogFailure failure) => failure.kind,
          'kind',
          CatalogFailureKind.unauthorized,
        ),
      );
    });
  });

  group('controllers and failures', () {
    test(
      'company mutation invalidates and refetches product providers',
      () async {
        final ProductDetail detail = _detail();
        final _FakeCompanyCatalogRepository company =
            _FakeCompanyCatalogRepository()..detail = detail;
        final ProviderContainer container = ProviderContainer(
          overrides: [
            catalogAccessStateProvider.overrideWithValue(
              const AsyncData<CatalogAccessState>(
                CatalogAccessState(
                  CatalogAudience.companyWorkflow,
                  companyDraftManagementAllowed: true,
                ),
              ),
            ),
            companyCatalogRepositoryProvider.overrideWithValue(company),
          ],
        );
        addTearDown(container.dispose);

        expect(
          await container.read(
            companyProductDetailProvider('product-id').future,
          ),
          same(detail),
        );
        await container.read(companyCatalogMutationController.future);

        await container
            .read(companyCatalogMutationController.notifier)
            .updateDraft(
              const UpdateProductDraftCommand(
                productId: 'product-id',
                category: ProductCategory.dietarySupplement,
                drugClassId: 'class-id',
              ),
            );

        expect(company.updateCalls, 1);
        expect(company.detailCalls, 2);
      },
    );

    test(
      'admin controller calls expected lifecycle repository method',
      () async {
        final _FakeAdminCatalogRepository admin = _FakeAdminCatalogRepository()
          ..detail = _detail();
        final ProviderContainer container = ProviderContainer(
          overrides: [
            catalogAccessStateProvider.overrideWithValue(
              const AsyncData<CatalogAccessState>(
                CatalogAccessState(CatalogAudience.administrator),
              ),
            ),
            adminCatalogRepositoryProvider.overrideWithValue(admin),
          ],
        );
        addTearDown(container.dispose);
        await container.read(adminCatalogLifecycleController.future);

        await container
            .read(adminCatalogLifecycleController.notifier)
            .requestChanges('product-id', 'Clarify indication');

        expect(admin.requestChangesCalls, 1);
        expect(admin.lastReason, 'Clarify indication');
        expect(admin.detailCalls, 1);
      },
    );

    test('admin media URL provider requires administrator access', () async {
      final _FakeAdminCatalogRepository admin = _FakeAdminCatalogRepository();
      final ProviderContainer denied = ProviderContainer(
        overrides: [
          catalogAccessStateProvider.overrideWithValue(
            const AsyncData<CatalogAccessState>(
              CatalogAccessState(CatalogAudience.officialCatalog),
            ),
          ),
          adminCatalogRepositoryProvider.overrideWithValue(admin),
        ],
      );
      addTearDown(denied.dispose);
      const CatalogMediaAccessRequest request = CatalogMediaAccessRequest(
        kind: CatalogMediaAssetKind.productMedia,
        storagePath: 'product-id/image.jpg',
      );

      final AsyncValue<Uri> deniedResult = await _waitForError(
        denied,
        adminCatalogMediaUrlProvider(request),
      );

      expect(
        deniedResult.error,
        isA<CatalogFailure>().having(
          (CatalogFailure failure) => failure.kind,
          'kind',
          CatalogFailureKind.unauthorized,
        ),
      );
      expect(admin.mediaReviewCalls, 0);

      final ProviderContainer allowed = ProviderContainer(
        overrides: [
          catalogAccessStateProvider.overrideWithValue(
            const AsyncData<CatalogAccessState>(
              CatalogAccessState(CatalogAudience.administrator),
            ),
          ),
          adminCatalogRepositoryProvider.overrideWithValue(admin),
        ],
      );
      addTearDown(allowed.dispose);

      final Uri result = await allowed.read(
        adminCatalogMediaUrlProvider(request).future,
      );

      expect(result, Uri.parse('https://example.test/secure-media'));
      expect(admin.mediaReviewCalls, 1);
    });

    test('provider errors preserve CatalogFailure', () async {
      const CatalogFailure failure = CatalogFailure(
        kind: CatalogFailureKind.serviceUnavailable,
        diagnosticCode: 'catalog_unavailable',
      );
      final _FakeOfficialCatalogRepository official =
          _FakeOfficialCatalogRepository()..failure = failure;
      final ProviderContainer container = ProviderContainer(
        overrides: [
          catalogAccessStateProvider.overrideWithValue(
            const AsyncData<CatalogAccessState>(
              CatalogAccessState(CatalogAudience.officialCatalog),
            ),
          ),
          officialCatalogRepositoryProvider.overrideWithValue(official),
        ],
      );
      addTearDown(container.dispose);

      final AsyncValue<List<ProductSummary>> result = await _waitForError(
        container,
        officialProductListProvider(const ProductListRequest()),
      );

      expect(result.error, same(failure));
    });
  });
}

Future<AsyncValue<T>> _waitForError<T>(
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider,
) async {
  final Completer<AsyncValue<T>> completer = Completer<AsyncValue<T>>();
  final ProviderSubscription<AsyncValue<T>> subscription = container.listen(
    provider,
    (AsyncValue<T>? previous, AsyncValue<T> next) {
      if (next.hasError && !completer.isCompleted) {
        completer.complete(next);
      }
    },
    fireImmediately: true,
  );
  try {
    return await completer.future.timeout(const Duration(seconds: 5));
  } finally {
    subscription.close();
  }
}

SessionPrincipal _principal(
  PlatformRole role, {
  String authUserId = 'user-id',
}) {
  final DateTime timestamp = DateTime.utc(2026);
  return SessionPrincipal(
    kind: switch (role) {
      PlatformRole.healthcareProfessional =>
        SessionPrincipalKind.healthcareProfessional,
      PlatformRole.companyUser => SessionPrincipalKind.companyUser,
      PlatformRole.admin ||
      PlatformRole.superAdmin => SessionPrincipalKind.administrator,
    },
    profile: Profile(
      id: 'profile-$authUserId',
      authUserId: authUserId,
      email: '$authUserId@example.com',
      role: role,
      status: ProfileStatus.active,
      createdAt: timestamp,
      updatedAt: timestamp,
    ),
  );
}

HealthcareProfessionalEligibilitySummary _eligibility(
  ProfessionType profession,
) => HealthcareProfessionalEligibilitySummary(
  professionalId: 'professional-id',
  profileId: 'profile-id',
  professionType: profession,
  verificationStatus: HealthcareProfessionalVerificationStatus.approved,
  profileStatus: ProfileStatus.active,
);

CatalogCompanyAccess _companyAccess(
  CompanyRole role, {
  CompanyStatus companyStatus = CompanyStatus.verified,
}) => CatalogCompanyAccess(
  companyId: 'company-id',
  companyName: 'Company',
  companyStatus: companyStatus,
  membershipId: 'membership-id',
  companyRole: role,
  isMembershipActive: true,
  profileStatus: ProfileStatus.active,
);

ProductDetail _detail() =>
    ProductDetailMapper.map(ProductDto.fromJson(draftProductJson()));

ProductSummary _summary() =>
    ProductSummaryMapper.map(ProductDto.fromJson(publishedProductJson()));

final class _FakeCatalogAccessRepository implements CatalogAccessRepository {
  HealthcareProfessionalEligibilitySummary? eligibility;
  CatalogCompanyAccess? companyAccess;

  @override
  Future<CatalogCompanyAccess?> getCurrentCompanyAccess() async =>
      companyAccess;

  @override
  Future<HealthcareProfessionalEligibilitySummary?>
  getHealthcareProfessionalEligibility() async => eligibility;
}

final class _FakeOfficialCatalogRepository
    implements OfficialCatalogRepository {
  List<ProductSummary> products = <ProductSummary>[];
  CatalogFailure? failure;
  int listCalls = 0;

  @override
  Future<List<ProductSummary>> listOfficialProducts(
    ProductListRequest request,
  ) async {
    listCalls += 1;
    if (failure case final CatalogFailure value) {
      throw value;
    }
    return products;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeCompanyCatalogRepository implements CompanyCatalogRepository {
  late ProductDetail detail;
  int listCalls = 0;
  int detailCalls = 0;
  int updateCalls = 0;

  @override
  Future<List<ProductSummary>> listOwnProducts({
    ProductLifecycleStatus? status,
  }) async {
    listCalls += 1;
    return <ProductSummary>[];
  }

  @override
  Future<ProductDetail> getOwnProductDetail(String productId) async {
    detailCalls += 1;
    return detail;
  }

  @override
  Future<ProductDetail> updateDraft(UpdateProductDraftCommand command) async {
    updateCalls += 1;
    return detail;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeAdminCatalogRepository implements AdminCatalogRepository {
  late ProductDetail detail;
  int requestChangesCalls = 0;
  int detailCalls = 0;
  int mediaReviewCalls = 0;
  String? lastReason;

  @override
  Future<ProductDetail> getProductDetail(String productId) async {
    detailCalls += 1;
    return detail;
  }

  @override
  Future<Uri> createMediaReviewUrl(CatalogMediaAccessRequest request) async {
    mediaReviewCalls += 1;
    return Uri.parse('https://example.test/secure-media');
  }

  @override
  Future<ProductDetail> requestChanges(String productId, String reason) async {
    requestChangesCalls += 1;
    lastReason = reason;
    return detail;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeCatalogTaxonomyRepository
    implements CatalogTaxonomyRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeAdminCatalogTaxonomyRepository
    implements AdminCatalogTaxonomyRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
