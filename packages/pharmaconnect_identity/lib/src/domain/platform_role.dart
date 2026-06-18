enum PlatformRole {
  healthcareProfessional('healthcare_professional'),
  companyUser('company_user'),
  admin('admin'),
  superAdmin('super_admin');

  const PlatformRole(this.databaseValue);

  final String databaseValue;

  static PlatformRole fromDatabaseValue(String value) {
    return PlatformRole.values.firstWhere(
      (PlatformRole role) => role.databaseValue == value,
      orElse: () => throw FormatException('Unknown platform role: $value'),
    );
  }
}
