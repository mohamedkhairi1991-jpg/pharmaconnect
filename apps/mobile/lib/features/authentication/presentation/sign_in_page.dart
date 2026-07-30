import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';
import 'package:pharmaconnect_mobile/features/authentication/application/auth_controller.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/auth_support.dart';

class MobileSignInPage extends ConsumerStatefulWidget {
  const MobileSignInPage({super.key});

  @override
  ConsumerState<MobileSignInPage> createState() => _MobileSignInPageState();
}

class _MobileSignInPageState extends ConsumerState<MobileSignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(mobileAuthControllerProvider)
          .signIn(_emailController.text, _passwordController.text);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      if (failure.kind == AuthFailureKind.emailNotConfirmed) {
        context.go('/auth/check-email', extra: _emailController.text.trim());
        return;
      }
      setState(() => _error = authFailureMessage(l10n, failure));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AuthScaffold(
      title: l10n.signInTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              key: const Key('mobileSignInEmail'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const <String>[AutofillHints.email],
              decoration: InputDecoration(labelText: l10n.emailLabel),
              validator: (String? value) => validateEmail(value, l10n),
            ),
            const SizedBox(height: PharmaConnectSpacing.medium),
            TextFormField(
              key: const Key('mobileSignInPassword'),
              controller: _passwordController,
              obscureText: true,
              autofillHints: const <String>[AutofillHints.password],
              decoration: InputDecoration(labelText: l10n.passwordLabel),
              validator: (String? value) => validatePassword(value, l10n),
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: PharmaConnectSpacing.medium),
              AuthMessageBanner(message: _error!, tone: AuthMessageTone.error),
            ],
            const SizedBox(height: PharmaConnectSpacing.large),
            FilledButton(
              key: const Key('mobileSignInSubmit'),
              onPressed: _loading ? null : _submit,
              child: AuthActionLabel(
                loading: _loading,
                label: l10n.signInAction,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/auth/forgot-password'),
              child: Text(l10n.forgotPasswordAction),
            ),
            TextButton(
              onPressed: () => context.go('/auth/sign-up'),
              child: Text('${l10n.createAccountPrompt} ${l10n.signUpAction}'),
            ),
          ],
        ),
      ),
    );
  }
}
