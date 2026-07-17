import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Pharamty'**
  String get appName;

  /// No description provided for @adminPortalLabel.
  ///
  /// In en, this message translates to:
  /// **'Administration portal'**
  String get adminPortalLabel;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @signInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInAction;

  /// No description provided for @signUpAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpAction;

  /// No description provided for @signOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutAction;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordAction;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get resetPasswordAction;

  /// No description provided for @sendResetLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLinkAction;

  /// No description provided for @resendConfirmationAction.
  ///
  /// In en, this message translates to:
  /// **'Resend confirmation'**
  String get resendConfirmationAction;

  /// No description provided for @checkEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmailTitle;

  /// No description provided for @checkEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Use the confirmation link in your email before signing in.'**
  String get checkEmailMessage;

  /// No description provided for @resetEmailSentMessage.
  ///
  /// In en, this message translates to:
  /// **'If an account exists, a password reset link has been sent.'**
  String get resetEmailSentMessage;

  /// No description provided for @confirmationSentMessage.
  ///
  /// In en, this message translates to:
  /// **'A new confirmation email has been requested.'**
  String get confirmationSentMessage;

  /// No description provided for @passwordUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password was updated. Sign in again.'**
  String get passwordUpdatedMessage;

  /// No description provided for @pendingAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account setup pending'**
  String get pendingAccountTitle;

  /// No description provided for @pendingAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is authenticated but is not yet assigned to an approved platform role.'**
  String get pendingAccountMessage;

  /// No description provided for @accountUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Account unavailable'**
  String get accountUnavailableTitle;

  /// No description provided for @accountUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'This account cannot currently access Pharamty.'**
  String get accountUnavailableMessage;

  /// No description provided for @unauthorizedClientTitle.
  ///
  /// In en, this message translates to:
  /// **'Use the correct application'**
  String get unauthorizedClientTitle;

  /// No description provided for @unauthorizedClientMessage.
  ///
  /// In en, this message translates to:
  /// **'This account is not authorized to use the administration portal.'**
  String get unauthorizedClientMessage;

  /// No description provided for @sessionLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Restoring your session…'**
  String get sessionLoadingMessage;

  /// No description provided for @sessionErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not restore your session.'**
  String get sessionErrorMessage;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @backToSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignInAction;

  /// No description provided for @createAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Need an account?'**
  String get createAccountPrompt;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @requiredFieldError.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredFieldError;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmailError;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get passwordLengthError;

  /// No description provided for @passwordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatchError;

  /// No description provided for @invalidCredentialsError.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect.'**
  String get invalidCredentialsError;

  /// No description provided for @emailNotConfirmedError.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email before signing in.'**
  String get emailNotConfirmedError;

  /// No description provided for @alreadyRegisteredError.
  ///
  /// In en, this message translates to:
  /// **'An account may already exist. Try signing in or resetting your password.'**
  String get alreadyRegisteredError;

  /// No description provided for @weakPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password.'**
  String get weakPasswordError;

  /// No description provided for @rateLimitedError.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait and try again.'**
  String get rateLimitedError;

  /// No description provided for @invalidRecoveryLinkError.
  ///
  /// In en, this message translates to:
  /// **'This recovery link is invalid or expired.'**
  String get invalidRecoveryLinkError;

  /// No description provided for @sessionExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again.'**
  String get sessionExpiredError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get networkError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unexpectedError;

  /// No description provided for @mobileAuthenticatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Authenticated'**
  String get mobileAuthenticatedTitle;

  /// No description provided for @mobileAuthenticatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your authenticated workspace will be added in a later phase.'**
  String get mobileAuthenticatedMessage;

  /// No description provided for @adminAuthenticatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Administration session'**
  String get adminAuthenticatedTitle;

  /// No description provided for @adminAuthenticatedMessage.
  ///
  /// In en, this message translates to:
  /// **'The administration dashboard will be added in a later phase.'**
  String get adminAuthenticatedMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
