enum ProfileStatus {
  pending('pending'),
  active('active'),
  suspended('suspended'),
  archived('archived');

  const ProfileStatus(this.databaseValue);

  final String databaseValue;

  static ProfileStatus fromDatabaseValue(String value) {
    return ProfileStatus.values.firstWhere(
      (ProfileStatus status) => status.databaseValue == value,
      orElse: () => throw FormatException('Unknown profile status: $value'),
    );
  }
}
