import 'package:flutter/material.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';

class AdminAuthScaffold extends StatelessWidget {
  const AdminAuthScaffold({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? adminValidateEmail(String? value, AppLocalizations l10n) {
  final String email = value?.trim() ?? '';
  if (email.isEmpty) return l10n.requiredFieldError;
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return l10n.invalidEmailError;
  }
  return null;
}

String? adminValidatePassword(String? value, AppLocalizations l10n) {
  if (value == null || value.isEmpty) return l10n.requiredFieldError;
  if (value.length < 8) return l10n.passwordLengthError;
  return null;
}

String adminAuthFailureMessage(AppLocalizations l10n, AuthFailure failure) {
  return switch (failure.kind) {
    AuthFailureKind.invalidCredentials => l10n.invalidCredentialsError,
    AuthFailureKind.emailNotConfirmed => l10n.emailNotConfirmedError,
    AuthFailureKind.alreadyRegistered => l10n.alreadyRegisteredError,
    AuthFailureKind.weakPassword => l10n.weakPasswordError,
    AuthFailureKind.rateLimited => l10n.rateLimitedError,
    AuthFailureKind.invalidRecoveryLink => l10n.invalidRecoveryLinkError,
    AuthFailureKind.sessionExpired => l10n.sessionExpiredError,
    AuthFailureKind.network => l10n.networkError,
    AuthFailureKind.unexpected => l10n.unexpectedError,
  };
}
