import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_admin/features/authentication/application/auth_controller.dart';
import 'package:pharmaconnect_admin/features/authentication/presentation/auth_support.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';

class AdminForgotPasswordPage extends ConsumerStatefulWidget {
  const AdminForgotPasswordPage({super.key});

  @override
  ConsumerState<AdminForgotPasswordPage> createState() =>
      _AdminForgotPasswordPageState();
}

class _AdminForgotPasswordPageState
    extends ConsumerState<AdminForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(adminAuthControllerProvider)
          .requestPasswordReset(_emailController.text);
    } on Object {
      // Return the same response to reduce account enumeration.
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _sent = true;
        });
      }
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
              key: const Key('adminForgotEmail'),
              controller: _emailController,
              decoration: InputDecoration(labelText: l10n.emailLabel),
              validator: (String? value) => adminValidateEmail(value, l10n),
            ),
            if (_sent) ...<Widget>[
              const SizedBox(height: 16),
              Text(l10n.resetEmailSentMessage),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('adminForgotSubmit'),
              onPressed: _loading ? null : _submit,
              child: Text(l10n.sendResetLinkAction),
            ),
            TextButton(
              onPressed: () => context.go('/auth/sign-in'),
              child: Text(l10n.backToSignInAction),
            ),
          ],
        ),
      ),
    );
  }
}
