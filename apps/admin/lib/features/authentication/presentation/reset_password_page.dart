import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_admin/features/authentication/application/auth_controller.dart';
import 'package:pharmaconnect_admin/features/authentication/presentation/auth_support.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';

class AdminResetPasswordPage extends ConsumerStatefulWidget {
  const AdminResetPasswordPage({super.key});

  @override
  ConsumerState<AdminResetPasswordPage> createState() =>
      _AdminResetPasswordPageState();
}

class _AdminResetPasswordPageState
    extends ConsumerState<AdminResetPasswordPage> {
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
      final AdminAuthController controller = ref.read(
        adminAuthControllerProvider,
      );
      await controller.updateRecoveredPassword(_passwordController.text);
      await controller.signOut();
      if (!mounted) return;
      context.go('/auth/sign-in');
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _error = adminAuthFailureMessage(l10n, failure));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AdminAuthScaffold(
      title: l10n.resetPasswordTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              key: const Key('adminResetPassword'),
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.passwordLabel),
              validator: (String? value) => adminValidatePassword(value, l10n),
            ),
            const SizedBox(height: PharmaConnectSpacing.medium),
            TextFormField(
              key: const Key('adminResetConfirmPassword'),
              controller: _confirmController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.confirmPasswordLabel),
              validator: (String? value) {
                final String? error = adminValidatePassword(value, l10n);
                if (error != null) return error;
                return value == _passwordController.text
                    ? null
                    : l10n.passwordMismatchError;
              },
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: PharmaConnectSpacing.medium),
              AdminAuthMessageBanner(
                message: _error!,
                tone: AdminAuthMessageTone.error,
              ),
            ],
            const SizedBox(height: PharmaConnectSpacing.large),
            FilledButton(
              key: const Key('adminResetSubmit'),
              onPressed: _loading ? null : _submit,
              child: AdminAuthActionLabel(
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
