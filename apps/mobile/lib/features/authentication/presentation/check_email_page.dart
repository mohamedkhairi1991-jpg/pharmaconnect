import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';
import 'package:pharmaconnect_mobile/features/authentication/application/auth_controller.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/auth_support.dart';

class MobileCheckEmailPage extends ConsumerStatefulWidget {
  const MobileCheckEmailPage({this.initialEmail, super.key});

  final String? initialEmail;

  @override
  ConsumerState<MobileCheckEmailPage> createState() =>
      _MobileCheckEmailPageState();
}

class _MobileCheckEmailPageState extends ConsumerState<MobileCheckEmailPage> {
  late final TextEditingController _emailController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await ref
          .read(mobileAuthControllerProvider)
          .resendConfirmation(_emailController.text);
      if (mounted) setState(() => _message = l10n.confirmationSentMessage);
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _message = authFailureMessage(l10n, failure));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AuthScaffold(
      title: l10n.checkEmailTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(l10n.checkEmailMessage),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('mobileConfirmationEmail'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.emailLabel),
              validator: (String? value) => validateEmail(value, l10n),
            ),
            if (_message != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(_message!),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('mobileResendConfirmation'),
              onPressed: _loading ? null : _resend,
              child: Text(l10n.resendConfirmationAction),
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
