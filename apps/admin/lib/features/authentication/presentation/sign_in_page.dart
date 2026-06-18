import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_admin/features/authentication/application/auth_controller.dart';
import 'package:pharmaconnect_admin/features/authentication/presentation/auth_support.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';

class AdminSignInPage extends ConsumerStatefulWidget {
  const AdminSignInPage({super.key});

  @override
  ConsumerState<AdminSignInPage> createState() => _AdminSignInPageState();
}

class _AdminSignInPageState extends ConsumerState<AdminSignInPage> {
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
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(adminAuthControllerProvider)
          .signIn(_emailController.text, _passwordController.text);
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
      title: l10n.signInTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              key: const Key('adminSignInEmail'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.emailLabel),
              validator: (String? value) => adminValidateEmail(value, l10n),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('adminSignInPassword'),
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.passwordLabel),
              validator: (String? value) => adminValidatePassword(value, l10n),
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('adminSignInSubmit'),
              onPressed: _loading ? null : _submit,
              child: Text(l10n.signInAction),
            ),
            TextButton(
              onPressed: () => context.go('/auth/forgot-password'),
              child: Text(l10n.forgotPasswordAction),
            ),
          ],
        ),
      ),
    );
  }
}
