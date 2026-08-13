import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';

import '../data/repository/supabase_admin_catalog_repository.dart';
import '../data/repository/supabase_admin_catalog_taxonomy_repository.dart';
import '../data/repository/supabase_catalog_access_repository.dart';
import '../data/repository/supabase_catalog_taxonomy_repository.dart';
import '../data/repository/supabase_company_catalog_repository.dart';
import '../data/repository/supabase_official_catalog_repository.dart';
import '../data/source/catalog_data_source.dart';
import '../domain/repository/catalog_repositories.dart';

final Provider<CatalogDataSource> _catalogDataSourceProvider =
    Provider<CatalogDataSource>(
      (Ref ref) => SupabaseCatalogDataSource(ref.watch(supabaseClientProvider)),
    );

final Provider<CatalogStorageDataSource> _catalogStorageDataSourceProvider =
    Provider<CatalogStorageDataSource>(
      (Ref ref) =>
          SupabaseCatalogStorageDataSource(ref.watch(supabaseClientProvider)),
    );

final Provider<CatalogAccessRepository> catalogAccessRepositoryProvider =
    Provider<CatalogAccessRepository>(
      (Ref ref) => SupabaseCatalogAccessRepository(
        ref.watch(_catalogDataSourceProvider),
      ),
    );

final Provider<OfficialCatalogRepository> officialCatalogRepositoryProvider =
    Provider<OfficialCatalogRepository>(
      (Ref ref) => SupabaseOfficialCatalogRepository(
        ref.watch(_catalogDataSourceProvider),
      ),
    );

final Provider<CompanyCatalogRepository> companyCatalogRepositoryProvider =
    Provider<CompanyCatalogRepository>(
      (Ref ref) => SupabaseCompanyCatalogRepository(
        ref.watch(_catalogDataSourceProvider),
        ref.watch(_catalogStorageDataSourceProvider),
      ),
    );

final Provider<AdminCatalogRepository> adminCatalogRepositoryProvider =
    Provider<AdminCatalogRepository>(
      (Ref ref) =>
          SupabaseAdminCatalogRepository(ref.watch(_catalogDataSourceProvider)),
    );

final Provider<CatalogTaxonomyRepository> catalogTaxonomyRepositoryProvider =
    Provider<CatalogTaxonomyRepository>(
      (Ref ref) => SupabaseCatalogTaxonomyRepository(
        ref.watch(_catalogDataSourceProvider),
      ),
    );

final Provider<AdminCatalogTaxonomyRepository>
adminCatalogTaxonomyRepositoryProvider =
    Provider<AdminCatalogTaxonomyRepository>(
      (Ref ref) => SupabaseAdminCatalogTaxonomyRepository(
        ref.watch(_catalogDataSourceProvider),
      ),
    );
