enum CatalogAudience {
  signedOut,
  pending,
  roleIneligible,
  suspended,
  officialCatalog,
  companyWorkflow,
  administrator,
}

final class CatalogAccessState {
  const CatalogAccessState(
    this.audience, {
    this.companyDraftManagementAllowed = false,
  });

  final CatalogAudience audience;
  final bool companyDraftManagementAllowed;

  bool get canReadOfficialCatalog =>
      audience == CatalogAudience.officialCatalog;

  bool get canReadCompanyWorkflow =>
      audience == CatalogAudience.companyWorkflow;

  bool get canManageCompanyDrafts =>
      audience == CatalogAudience.companyWorkflow &&
      companyDraftManagementAllowed;

  bool get canAdministerCatalog => audience == CatalogAudience.administrator;
}
