import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';
import 'package:pharmaconnect_mobile/features/authentication/application/auth_controller.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/auth_support.dart';

class MobileSessionLoadingPage extends StatelessWidget {
  const MobileSessionLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AppLocalizations.of(context).sessionLoadingMessage),
      ),
    );
  }
}

class MobileSessionStatusPage extends ConsumerWidget {
  const MobileSessionStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AuthScaffold(
      title: l10n.pendingAccountTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(l10n.pendingAccountMessage),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => ref.read(mobileAuthControllerProvider).signOut(),
            child: Text(l10n.signOutAction),
          ),
        ],
      ),
    );
  }
}

class MobileAccountUnavailablePage extends ConsumerWidget {
  const MobileAccountUnavailablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AuthScaffold(
      title: l10n.accountUnavailableTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(l10n.accountUnavailableMessage),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => ref.read(mobileAuthControllerProvider).signOut(),
            child: Text(l10n.signOutAction),
          ),
        ],
      ),
    );
  }
}

class MobileAuthenticatedShellPage extends ConsumerWidget {
  const MobileAuthenticatedShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AuthScaffold(
      title: l10n.mobileAuthenticatedTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(l10n.mobileAuthenticatedMessage),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => ref.read(mobileAuthControllerProvider).signOut(),
            child: Text(l10n.signOutAction),
          ),
        ],
      ),
    );
  }
}
