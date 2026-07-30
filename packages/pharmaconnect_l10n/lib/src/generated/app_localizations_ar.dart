// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Pharamty';

  @override
  String get adminPortalLabel => 'بوابة الإدارة';

  @override
  String get signInTitle => 'تسجيل الدخول';

  @override
  String get signUpTitle => 'إنشاء حساب';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get signInAction => 'تسجيل الدخول';

  @override
  String get signUpAction => 'إنشاء الحساب';

  @override
  String get signOutAction => 'تسجيل الخروج';

  @override
  String get forgotPasswordAction => 'هل نسيت كلمة المرور؟';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordAction => 'تحديث كلمة المرور';

  @override
  String get sendResetLinkAction => 'إرسال رابط الاستعادة';

  @override
  String get resendConfirmationAction => 'إعادة إرسال التأكيد';

  @override
  String get checkEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get checkEmailMessage =>
      'استخدم رابط التأكيد المرسل إلى بريدك قبل تسجيل الدخول.';

  @override
  String get resetEmailSentMessage =>
      'إذا كان الحساب موجوداً، فسيتم إرسال رابط إعادة تعيين كلمة المرور.';

  @override
  String get confirmationSentMessage => 'تم طلب إرسال رسالة تأكيد جديدة.';

  @override
  String get passwordUpdatedMessage =>
      'تم تحديث كلمة المرور. سجّل الدخول مرة أخرى.';

  @override
  String get pendingAccountTitle => 'إعداد الحساب قيد الانتظار';

  @override
  String get pendingAccountMessage =>
      'تم توثيق حسابك، لكنه لم يُسند بعد إلى دور معتمد في المنصة.';

  @override
  String get accountUnavailableTitle => 'الحساب غير متاح';

  @override
  String get accountUnavailableMessage =>
      'لا يمكن لهذا الحساب الوصول إلى Pharamty حالياً.';

  @override
  String get unauthorizedClientTitle => 'استخدم التطبيق الصحيح';

  @override
  String get unauthorizedClientMessage =>
      'هذا الحساب غير مخول لاستخدام بوابة الإدارة.';

  @override
  String get sessionLoadingMessage => 'جارٍ استعادة جلستك…';

  @override
  String get sessionErrorMessage => 'تعذر استعادة جلستك.';

  @override
  String get retryAction => 'إعادة المحاولة';

  @override
  String get backToSignInAction => 'العودة لتسجيل الدخول';

  @override
  String get createAccountPrompt => 'هل تحتاج إلى حساب؟';

  @override
  String get alreadyHaveAccountPrompt => 'هل لديك حساب بالفعل؟';

  @override
  String get requiredFieldError => 'هذا الحقل مطلوب.';

  @override
  String get invalidEmailError => 'أدخل بريداً إلكترونياً صالحاً.';

  @override
  String get passwordLengthError => 'استخدم 8 أحرف على الأقل.';

  @override
  String get passwordMismatchError => 'كلمتا المرور غير متطابقتين.';

  @override
  String get invalidCredentialsError =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get emailNotConfirmedError => 'أكد بريدك الإلكتروني قبل تسجيل الدخول.';

  @override
  String get alreadyRegisteredError =>
      'قد يكون الحساب موجوداً. جرّب تسجيل الدخول أو إعادة تعيين كلمة المرور.';

  @override
  String get weakPasswordError => 'اختر كلمة مرور أقوى.';

  @override
  String get rateLimitedError => 'محاولات كثيرة. انتظر ثم حاول مجدداً.';

  @override
  String get invalidRecoveryLinkError => 'رابط الاستعادة غير صالح أو منتهي.';

  @override
  String get sessionExpiredError => 'انتهت جلستك. سجّل الدخول مرة أخرى.';

  @override
  String get networkError => 'تحقق من الاتصال وحاول مجدداً.';

  @override
  String get unexpectedError => 'حدث خطأ. حاول مجدداً.';

  @override
  String get mobileAuthenticatedTitle => 'تم تسجيل الدخول';

  @override
  String get mobileAuthenticatedMessage =>
      'ستتم إضافة مساحة العمل في مرحلة لاحقة.';

  @override
  String get adminAuthenticatedTitle => 'جلسة الإدارة';

  @override
  String get adminAuthenticatedMessage =>
      'ستتم إضافة لوحة الإدارة في مرحلة لاحقة.';
}
