import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';
import 'package:pharmaconnect_mobile/features/authentication/application/auth_controller.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/auth_support.dart';

class MobileResetPasswordPage extends ConsumerStatefulWidget {
  const MobileResetPasswordPage({super.key});

  @override
  ConsumerState<MobileResetPasswordPage> createState() =>
      _MobileResetPasswordPageState();
}

class _MobileResetPasswordPageState
    extends ConsumerState<MobileResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final MobileAuthController controller = ref.read(
        mobileAuthControllerProvider,
      );
      await controller.updateRecoveredPassword(_passwordController.text);
      await controller.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.passwordUpdatedMessage)));
      context.go('/auth/sign-in');
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = authFailureMessage(l10n, failure));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AuthScaffold(
      title: l10n.resetPasswordTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              key: const Key('mobileResetPassword'),
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.passwordLabel),
              validator: (String? value) => validatePassword(value, l10n),
            ),
            const SizedBox(height: PharmaConnectSpacing.medium),
            TextFormField(
              key: const Key('mobileResetConfirmPassword'),
              controller: _confirmController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.confirmPasswordLabel),
              validator: (String? value) {
                final String? error = validatePassword(value, l10n);
                if (error != null) return error;
                return value == _passwordController.text
                    ? null
                    : l10n.passwordMismatchError;
              },
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: PharmaConnectSpacing.medium),
              AuthMessageBanner(message: _error!, tone: AuthMessageTone.error),
            ],
            const SizedBox(height: PharmaConnectSpacing.large),
            FilledButton(
              key: const Key('mobileResetSubmit'),
              onPressed: _loading ? null : _submit,
              child: AuthActionLabel(
                loading: _loading,
                label: l10n.resetPasswordAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
