import 'package:flutter/material.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.child,
    this.leadingIcon = Icons.medical_information_outlined,
    super.key,
  });

  final String title;
  final Widget child;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              PharmaConnectColors.deepBlue,
              PharmaConnectColors.canvas,
              PharmaConnectColors.canvas,
            ],
            stops: <double>[0, 0.42, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(PharmaConnectSpacing.large),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _MobileAuthBrand(),
                    const SizedBox(height: PharmaConnectSpacing.large),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(
                          PharmaConnectSpacing.large,
                        ),
                        child: FocusTraversalGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color:
                                        PharmaConnectColors.unresolvedContainer,
                                    border: Border.all(
                                      color:
                                          PharmaConnectColors.unresolvedBorder,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      PharmaConnectRadii.control,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      PharmaConnectSpacing.compact,
                                    ),
                                    child: Icon(
                                      leadingIcon,
                                      color: PharmaConnectColors.linkFocus,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: PharmaConnectSpacing.medium,
                              ),
                              Text(
                                title,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(
                                height: PharmaConnectSpacing.large,
                              ),
                              child,
                            ],
                          ),
                        ),
                      ),
                    ),
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

class _MobileAuthBrand extends StatelessWidget {
  const _MobileAuthBrand();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: PharmaConnectColors.primary,
              borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
              border: Border.all(color: PharmaConnectColors.linkFocus),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: PharmaConnectColors.primaryText,
              size: 26,
            ),
          ),
          const SizedBox(width: PharmaConnectSpacing.medium),
          Text('Pharamty', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}

enum AuthMessageTone { information, success, warning, error }

class AuthMessageBanner extends StatelessWidget {
  const AuthMessageBanner({
    required this.message,
    this.tone = AuthMessageTone.information,
    super.key,
  });

  final String message;
  final AuthMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final PharmaConnectStatusPresentation presentation = switch (tone) {
      AuthMessageTone.information =>
        PharmaConnectSemanticStatusMapper.unresolved,
      AuthMessageTone.success => PharmaConnectSemanticStatusMapper.success,
      AuthMessageTone.warning => PharmaConnectSemanticStatusMapper.warning,
      AuthMessageTone.error => PharmaConnectSemanticStatusMapper.error,
    };
    final IconData icon = switch (tone) {
      AuthMessageTone.information => Icons.info_outline,
      AuthMessageTone.success => Icons.check_circle_outline,
      AuthMessageTone.warning => Icons.schedule_outlined,
      AuthMessageTone.error => Icons.error_outline,
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(PharmaConnectSpacing.compact),
        decoration: BoxDecoration(
          color: presentation.container,
          border: Border.all(color: presentation.border),
          borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: presentation.foreground, size: 20),
            const SizedBox(width: PharmaConnectSpacing.small),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: presentation.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthActionLabel extends StatelessWidget {
  const AuthActionLabel({
    required this.loading,
    required this.label,
    super.key,
  });

  final bool loading;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (!loading) {
      return Text(label);
    }
    return const SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: PharmaConnectColors.primaryText,
      ),
    );
  }
}

class AuthStatusPanel extends StatelessWidget {
  const AuthStatusPanel({
    required this.message,
    required this.icon,
    this.tone = AuthMessageTone.information,
    super.key,
  });

  final String message;
  final IconData icon;
  final AuthMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final PharmaConnectStatusPresentation presentation = switch (tone) {
      AuthMessageTone.information =>
        PharmaConnectSemanticStatusMapper.unresolved,
      AuthMessageTone.success => PharmaConnectSemanticStatusMapper.success,
      AuthMessageTone.warning => PharmaConnectSemanticStatusMapper.warning,
      AuthMessageTone.error => PharmaConnectSemanticStatusMapper.error,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            padding: const EdgeInsets.all(PharmaConnectSpacing.medium),
            decoration: BoxDecoration(
              color: presentation.container,
              border: Border.all(color: presentation.border),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: presentation.foreground, size: 28),
          ),
        ),
        const SizedBox(height: PharmaConnectSpacing.medium),
        Text(message, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

String? validateEmail(String? value, AppLocalizations l10n) {
  final String email = value?.trim() ?? '';
  if (email.isEmpty) {
    return l10n.requiredFieldError;
  }
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return l10n.invalidEmailError;
  }
  return null;
}

String? validatePassword(String? value, AppLocalizations l10n) {
  if (value == null || value.isEmpty) {
    return l10n.requiredFieldError;
  }
  if (value.length < 8) {
    return l10n.passwordLengthError;
  }
  return null;
}

String authFailureMessage(AppLocalizations l10n, AuthFailure failure) {
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
