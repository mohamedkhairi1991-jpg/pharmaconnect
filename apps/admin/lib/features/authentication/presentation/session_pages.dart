import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_admin/features/authentication/application/auth_controller.dart';
import 'package:pharmaconnect_admin/features/authentication/presentation/auth_support.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';

class AdminSessionLoadingPage extends StatelessWidget {
  const AdminSessionLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AdminAuthScaffold(
      title: l10n.sessionLoadingMessage,
      leadingIcon: Icons.sync_outlined,
      child: const LinearProgressIndicator(),
    );
  }
}

class AdminUnauthorizedPage extends ConsumerWidget {
  const AdminUnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AdminAuthScaffold(
      title: l10n.unauthorizedClientTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AdminAuthStatusPanel(
            message: l10n.unauthorizedClientMessage,
            icon: Icons.admin_panel_settings_outlined,
            tone: AdminAuthMessageTone.error,
          ),
          const SizedBox(height: PharmaConnectSpacing.large),
          OutlinedButton(
            onPressed: () => ref.read(adminAuthControllerProvider).signOut(),
            child: Text(l10n.signOutAction),
          ),
        ],
      ),
    );
  }
}

class AdminAccountUnavailablePage extends ConsumerWidget {
  const AdminAccountUnavailablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AdminAuthScaffold(
      title: l10n.accountUnavailableTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AdminAuthStatusPanel(
            message: l10n.accountUnavailableMessage,
            icon: Icons.lock_outline,
            tone: AdminAuthMessageTone.error,
          ),
          const SizedBox(height: PharmaConnectSpacing.large),
          OutlinedButton(
            onPressed: () => ref.read(adminAuthControllerProvider).signOut(),
            child: Text(l10n.signOutAction),
          ),
        ],
      ),
    );
  }
}

class AdminAuthenticatedShellPage extends ConsumerWidget {
  const AdminAuthenticatedShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AdminAuthScaffold(
      title: l10n.adminAuthenticatedTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AdminAuthStatusPanel(
            message: l10n.adminAuthenticatedMessage,
            icon: Icons.verified_user_outlined,
            tone: AdminAuthMessageTone.success,
          ),
          const SizedBox(height: PharmaConnectSpacing.large),
          OutlinedButton(
            onPressed: () => ref.read(adminAuthControllerProvider).signOut(),
            child: Text(l10n.signOutAction),
          ),
        ],
      ),
    );
  }
}
