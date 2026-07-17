import 'package:flutter/material.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';

class AdminAuthScaffold extends StatelessWidget {
  const AdminAuthScaffold({
    required this.title,
    required this.child,
    this.leadingIcon = Icons.admin_panel_settings_outlined,
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
            stops: <double>[0, 0.36, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(PharmaConnectSpacing.xLarge),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final Widget card = _AdminAuthCard(
                      title: title,
                      leadingIcon: leadingIcon,
                      child: child,
                    );
                    if (constraints.maxWidth < 760) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const _AdminAuthBrand(compact: true),
                          const SizedBox(height: PharmaConnectSpacing.large),
                          card,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Expanded(child: _AdminAuthBrand()),
                        const SizedBox(width: PharmaConnectSpacing.xxLarge),
                        Expanded(child: card),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminAuthBrand extends StatelessWidget {
  const _AdminAuthBrand({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: compact
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: compact ? 52 : 64,
            height: compact ? 52 : 64,
            decoration: BoxDecoration(
              color: PharmaConnectColors.primary,
              borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
              border: Border.all(color: PharmaConnectColors.linkFocus),
            ),
            child: Icon(
              Icons.health_and_safety_outlined,
              color: PharmaConnectColors.primaryText,
              size: compact ? 28 : 34,
            ),
          ),
          const SizedBox(height: PharmaConnectSpacing.medium),
          Text('Pharamty', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: PharmaConnectSpacing.small),
          Text(
            AppLocalizations.of(context).adminPortalLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: PharmaConnectColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminAuthCard extends StatelessWidget {
  const _AdminAuthCard({
    required this.title,
    required this.leadingIcon,
    required this.child,
  });

  final String title;
  final IconData leadingIcon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(PharmaConnectSpacing.xLarge),
        child: FocusTraversalGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: PharmaConnectColors.unresolvedContainer,
                    border: Border.all(
                      color: PharmaConnectColors.unresolvedBorder,
                    ),
                    borderRadius: BorderRadius.circular(
                      PharmaConnectRadii.control,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(PharmaConnectSpacing.compact),
                    child: Icon(
                      leadingIcon,
                      color: PharmaConnectColors.linkFocus,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: PharmaConnectSpacing.medium),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: PharmaConnectSpacing.large),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

enum AdminAuthMessageTone { information, success, warning, error }

class AdminAuthMessageBanner extends StatelessWidget {
  const AdminAuthMessageBanner({
    required this.message,
    this.tone = AdminAuthMessageTone.information,
    super.key,
  });

  final String message;
  final AdminAuthMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final PharmaConnectStatusPresentation presentation = switch (tone) {
      AdminAuthMessageTone.information =>
        PharmaConnectSemanticStatusMapper.unresolved,
      AdminAuthMessageTone.success => PharmaConnectSemanticStatusMapper.success,
      AdminAuthMessageTone.warning => PharmaConnectSemanticStatusMapper.warning,
      AdminAuthMessageTone.error => PharmaConnectSemanticStatusMapper.error,
    };
    final IconData icon = switch (tone) {
      AdminAuthMessageTone.information => Icons.info_outline,
      AdminAuthMessageTone.success => Icons.check_circle_outline,
      AdminAuthMessageTone.warning => Icons.schedule_outlined,
      AdminAuthMessageTone.error => Icons.error_outline,
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

class AdminAuthActionLabel extends StatelessWidget {
  const AdminAuthActionLabel({
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

class AdminAuthStatusPanel extends StatelessWidget {
  const AdminAuthStatusPanel({
    required this.message,
    required this.icon,
    this.tone = AdminAuthMessageTone.information,
    super.key,
  });

  final String message;
  final IconData icon;
  final AdminAuthMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final PharmaConnectStatusPresentation presentation = switch (tone) {
      AdminAuthMessageTone.information =>
        PharmaConnectSemanticStatusMapper.unresolved,
      AdminAuthMessageTone.success => PharmaConnectSemanticStatusMapper.success,
      AdminAuthMessageTone.warning => PharmaConnectSemanticStatusMapper.warning,
      AdminAuthMessageTone.error => PharmaConnectSemanticStatusMapper.error,
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
