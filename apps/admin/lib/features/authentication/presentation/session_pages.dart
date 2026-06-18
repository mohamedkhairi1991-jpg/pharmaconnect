import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_admin/features/authentication/application/auth_controller.dart';
import 'package:pharmaconnect_admin/features/authentication/presentation/auth_support.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';

class AdminSessionLoadingPage extends StatelessWidget {
  const AdminSessionLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AppLocalizations.of(context).sessionLoadingMessage),
      ),
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
          Text(l10n.unauthorizedClientMessage),
          const SizedBox(height: 24),
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
          Text(l10n.accountUnavailableMessage),
          const SizedBox(height: 24),
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
          Text(l10n.adminAuthenticatedMessage),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => ref.read(adminAuthControllerProvider).signOut(),
            child: Text(l10n.signOutAction),
          ),
        ],
      ),
    );
  }
}
