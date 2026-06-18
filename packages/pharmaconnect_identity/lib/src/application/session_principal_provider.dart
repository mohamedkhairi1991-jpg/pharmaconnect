import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';

import '../domain/platform_role.dart';
import '../domain/profile.dart';
import '../domain/profile_status.dart';
import '../domain/session_principal.dart';
import 'current_profile_provider.dart';

final FutureProvider<SessionPrincipal?> sessionPrincipalProvider =
    FutureProvider<SessionPrincipal?>((Ref ref) async {
      final AuthSessionState authState = await ref.watch(
        authStateProvider.future,
      );

      if (!authState.isAuthenticated) {
        return null;
      }

      final Profile? profile = await ref.watch(currentProfileProvider.future);
      if (profile == null) {
        return const SessionPrincipal(
          kind: SessionPrincipalKind.profileUnavailable,
          profile: null,
        );
      }

      if (profile.status == ProfileStatus.suspended) {
        return SessionPrincipal(
          kind: SessionPrincipalKind.suspended,
          profile: profile,
        );
      }
      if (profile.status == ProfileStatus.archived) {
        return SessionPrincipal(
          kind: SessionPrincipalKind.archived,
          profile: profile,
        );
      }
      if (profile.status == ProfileStatus.pending || profile.role == null) {
        return SessionPrincipal(
          kind: SessionPrincipalKind.pending,
          profile: profile,
        );
      }

      return SessionPrincipal(
        kind: switch (profile.role!) {
          PlatformRole.healthcareProfessional =>
            SessionPrincipalKind.healthcareProfessional,
          PlatformRole.companyUser => SessionPrincipalKind.companyUser,
          PlatformRole.admin ||
          PlatformRole.superAdmin => SessionPrincipalKind.administrator,
        },
        profile: profile,
      );
    });
