import 'profile.dart';

enum SessionPrincipalKind {
  profileUnavailable,
  pending,
  healthcareProfessional,
  companyUser,
  administrator,
  suspended,
  archived,
}

class SessionPrincipal {
  const SessionPrincipal({required this.kind, required this.profile});

  final SessionPrincipalKind kind;
  final Profile? profile;
}
