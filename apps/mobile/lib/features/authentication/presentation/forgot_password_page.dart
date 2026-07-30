import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';
import 'package:pharmaconnect_mobile/features/authentication/application/auth_controller.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/auth_support.dart';

class MobileForgotPasswordPage extends ConsumerStatefulWidget {
  const MobileForgotPasswordPage({super.key});

  @override
  ConsumerState<MobileForgotPasswordPage> createState() =>
      _MobileForgotPasswordPageState();
}

class _MobileForgotPasswordPageState
    extends ConsumerState<MobileForgotPasswordPage> {
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
          .read(mobileAuthControllerProvider)
          .requestPasswordReset(_emailController.text);
    } on Object {
      // Intentionally return the same response to reduce account enumeration.
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
    return AuthScaffold(
      title: l10n.resetPasswordTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              key: const Key('mobileForgotEmail'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.emailLabel),
              validator: (String? value) => validateEmail(value, l10n),
            ),
            if (_sent) ...<Widget>[
              const SizedBox(height: PharmaConnectSpacing.medium),
              AuthMessageBanner(
                message: l10n.resetEmailSentMessage,
                tone: AuthMessageTone.success,
              ),
            ],
            const SizedBox(height: PharmaConnectSpacing.large),
            FilledButton(
              key: const Key('mobileForgotSubmit'),
              onPressed: _loading ? null : _submit,
              child: AuthActionLabel(
                loading: _loading,
                label: l10n.sendResetLinkAction,
              ),
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
