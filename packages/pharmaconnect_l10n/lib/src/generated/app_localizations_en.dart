// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pharamty';

  @override
  String get adminPortalLabel => 'Administration portal';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get signInAction => 'Sign in';

  @override
  String get signUpAction => 'Create account';

  @override
  String get signOutAction => 'Sign out';

  @override
  String get forgotPasswordAction => 'Forgot password?';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordAction => 'Update password';

  @override
  String get sendResetLinkAction => 'Send reset link';

  @override
  String get resendConfirmationAction => 'Resend confirmation';

  @override
  String get checkEmailTitle => 'Check your email';

  @override
  String get checkEmailMessage =>
      'Use the confirmation link in your email before signing in.';

  @override
  String get resetEmailSentMessage =>
      'If an account exists, a password reset link has been sent.';

  @override
  String get confirmationSentMessage =>
      'A new confirmation email has been requested.';

  @override
  String get passwordUpdatedMessage =>
      'Your password was updated. Sign in again.';

  @override
  String get pendingAccountTitle => 'Account setup pending';

  @override
  String get pendingAccountMessage =>
      'Your account is authenticated but is not yet assigned to an approved platform role.';

  @override
  String get accountUnavailableTitle => 'Account unavailable';

  @override
  String get accountUnavailableMessage =>
      'This account cannot currently access Pharamty.';

  @override
  String get unauthorizedClientTitle => 'Use the correct application';

  @override
  String get unauthorizedClientMessage =>
      'This account is not authorized to use the administration portal.';

  @override
  String get sessionLoadingMessage => 'Restoring your session…';

  @override
  String get sessionErrorMessage => 'We could not restore your session.';

  @override
  String get retryAction => 'Retry';

  @override
  String get backToSignInAction => 'Back to sign in';

  @override
  String get createAccountPrompt => 'Need an account?';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account?';

  @override
  String get requiredFieldError => 'This field is required.';

  @override
  String get invalidEmailError => 'Enter a valid email address.';

  @override
  String get passwordLengthError => 'Use at least 8 characters.';

  @override
  String get passwordMismatchError => 'Passwords do not match.';

  @override
  String get invalidCredentialsError => 'The email or password is incorrect.';

  @override
  String get emailNotConfirmedError => 'Confirm your email before signing in.';

  @override
  String get alreadyRegisteredError =>
      'An account may already exist. Try signing in or resetting your password.';

  @override
  String get weakPasswordError => 'Choose a stronger password.';

  @override
  String get rateLimitedError =>
      'Too many attempts. Please wait and try again.';

  @override
  String get invalidRecoveryLinkError =>
      'This recovery link is invalid or expired.';

  @override
  String get sessionExpiredError => 'Your session expired. Sign in again.';

  @override
  String get networkError => 'Check your connection and try again.';

  @override
  String get unexpectedError => 'Something went wrong. Please try again.';

  @override
  String get mobileAuthenticatedTitle => 'Authenticated';

  @override
  String get mobileAuthenticatedMessage =>
      'Your authenticated workspace will be added in a later phase.';

  @override
  String get adminAuthenticatedTitle => 'Administration session';

  @override
  String get adminAuthenticatedMessage =>
      'The administration dashboard will be added in a later phase.';
}
