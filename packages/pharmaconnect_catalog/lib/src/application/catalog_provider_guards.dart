import '../domain/failure/catalog_failure.dart';
import 'catalog_access_state.dart';

CatalogFailure catalogAccessDenied(CatalogAccessState access) {
  return CatalogFailure(
    kind: access.audience == CatalogAudience.signedOut
        ? CatalogFailureKind.unauthenticated
        : CatalogFailureKind.unauthorized,
    diagnosticCode: 'catalog_provider_${access.audience.name}',
  );
}

void requireOfficialCatalogAccess(CatalogAccessState access) {
  if (!access.canReadOfficialCatalog) {
    throw catalogAccessDenied(access);
  }
}

void requireCompanyWorkflowAccess(
  CatalogAccessState access, {
  bool requireDraftManagement = false,
}) {
  final bool allowed = requireDraftManagement
      ? access.canManageCompanyDrafts
      : access.canReadCompanyWorkflow;
  if (!allowed) {
    throw catalogAccessDenied(access);
  }
}

void requireAdministratorAccess(CatalogAccessState access) {
  if (!access.canAdministerCatalog) {
    throw catalogAccessDenied(access);
  }
}

void requireTaxonomyAccess(CatalogAccessState access) {
  if (!access.canReadCompanyWorkflow && !access.canAdministerCatalog) {
    throw catalogAccessDenied(access);
  }
}
