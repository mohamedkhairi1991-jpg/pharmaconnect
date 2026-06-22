import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

import '../domain/access/catalog_company_access.dart';
import '../domain/access/healthcare_professional_eligibility_summary.dart';
import 'catalog_access_state.dart';
import 'catalog_repository_providers.dart';

final FutureProvider<HealthcareProfessionalEligibilitySummary?>
healthcareProfessionalEligibilityProvider =
    FutureProvider<HealthcareProfessionalEligibilitySummary?>((Ref ref) async {
      final SessionPrincipal? principal = await ref.watch(
        sessionPrincipalProvider.future,
      );
      if (principal?.kind != SessionPrincipalKind.healthcareProfessional) {
        return null;
      }
      return ref
          .watch(catalogAccessRepositoryProvider)
          .getHealthcareProfessionalEligibility();
    });

final FutureProvider<CatalogCompanyAccess?>
currentCatalogCompanyAccessProvider = FutureProvider<CatalogCompanyAccess?>((
  Ref ref,
) async {
  final SessionPrincipal? principal = await ref.watch(
    sessionPrincipalProvider.future,
  );
  if (principal?.kind != SessionPrincipalKind.companyUser) {
    return null;
  }
  return ref.watch(catalogAccessRepositoryProvider).getCurrentCompanyAccess();
});

final FutureProvider<CatalogAccessState> catalogAccessStateProvider =
    FutureProvider<CatalogAccessState>((Ref ref) async {
      final SessionPrincipal? principal = await ref.watch(
        sessionPrincipalProvider.future,
      );
      if (principal == null) {
        return const CatalogAccessState(CatalogAudience.signedOut);
      }

      switch (principal.kind) {
        case SessionPrincipalKind.profileUnavailable:
        case SessionPrincipalKind.pending:
          return const CatalogAccessState(CatalogAudience.pending);
        case SessionPrincipalKind.suspended:
        case SessionPrincipalKind.archived:
          return const CatalogAccessState(CatalogAudience.suspended);
        case SessionPrincipalKind.administrator:
          return const CatalogAccessState(CatalogAudience.administrator);
        case SessionPrincipalKind.healthcareProfessional:
          final HealthcareProfessionalEligibilitySummary? eligibility =
              await ref.watch(healthcareProfessionalEligibilityProvider.future);
          return CatalogAccessState(
            eligibility?.isOfficialCatalogEligible == true
                ? CatalogAudience.officialCatalog
                : CatalogAudience.roleIneligible,
          );
        case SessionPrincipalKind.companyUser:
          final CatalogCompanyAccess? companyAccess = await ref.watch(
            currentCatalogCompanyAccessProvider.future,
          );
          if (companyAccess?.canReadWorkflow != true) {
            return const CatalogAccessState(CatalogAudience.roleIneligible);
          }
          return CatalogAccessState(
            CatalogAudience.companyWorkflow,
            companyDraftManagementAllowed:
                companyAccess?.canManageDrafts == true,
          );
      }
    });
