import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('en'),
    Locale('ro'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Ana Fit Lab'**
  String get appName;

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

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'10–64 characters'**
  String get passwordHint;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goToLogin;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get goHome;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cantReachServer.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server'**
  String get cantReachServer;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @newCoachPrompt.
  ///
  /// In en, this message translates to:
  /// **'New coach?'**
  String get newCoachPrompt;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccountLink;

  /// No description provided for @sessionEndedNotice.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Please sign in again.'**
  String get sessionEndedNotice;

  /// No description provided for @accountSuspendedNotice.
  ///
  /// In en, this message translates to:
  /// **'Your account is suspended.'**
  String get accountSuspendedNotice;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your coach account'**
  String get registerTitle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerButton;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccountPrompt;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @joinTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re joining {coachName}\'s coaching'**
  String joinTitle(String coachName);

  /// No description provided for @joinButton.
  ///
  /// In en, this message translates to:
  /// **'Create account and join'**
  String get joinButton;

  /// No description provided for @joinSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You\'re signed in as {email}'**
  String joinSignedIn(String email);

  /// No description provided for @joinSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out to create a new account'**
  String get joinSignOut;

  /// No description provided for @verifyingEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirming your email…'**
  String get verifyingEmail;

  /// No description provided for @emailConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed'**
  String get emailConfirmedTitle;

  /// No description provided for @emailConfirmedText.
  ///
  /// In en, this message translates to:
  /// **'Your account is ready.'**
  String get emailConfirmedText;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotTitle;

  /// No description provided for @forgotText.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link.'**
  String get forgotText;

  /// No description provided for @forgotButton.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotButton;

  /// No description provided for @forgotSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, we\'ve sent a link to reset the password.'**
  String get forgotSent;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get resetTitle;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get resetButton;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {firstName}'**
  String homeGreeting(String firstName);

  /// No description provided for @roleCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get roleCoach;

  /// No description provided for @roleClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get roleClient;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @pendingBanner.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email – we sent a link to {email}'**
  String pendingBanner(String email);

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @resent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get resent;

  /// No description provided for @linkInviteExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'This invite has expired'**
  String get linkInviteExpiredTitle;

  /// No description provided for @linkInviteExpiredText.
  ///
  /// In en, this message translates to:
  /// **'Ask your coach for a new one.'**
  String get linkInviteExpiredText;

  /// No description provided for @linkInviteUsedTitle.
  ///
  /// In en, this message translates to:
  /// **'This invite was already used'**
  String get linkInviteUsedTitle;

  /// No description provided for @linkInviteUsedText.
  ///
  /// In en, this message translates to:
  /// **'If it was you, sign in.'**
  String get linkInviteUsedText;

  /// No description provided for @linkInviteRevokedTitle.
  ///
  /// In en, this message translates to:
  /// **'This invite is no longer valid'**
  String get linkInviteRevokedTitle;

  /// No description provided for @linkInviteRevokedText.
  ///
  /// In en, this message translates to:
  /// **'Ask your coach for a new one.'**
  String get linkInviteRevokedText;

  /// No description provided for @linkInviteNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this invite'**
  String get linkInviteNotFoundTitle;

  /// No description provided for @linkInviteNotFoundText.
  ///
  /// In en, this message translates to:
  /// **'Check the link and try again.'**
  String get linkInviteNotFoundText;

  /// No description provided for @linkCoachUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Your coach isn\'t available right now'**
  String get linkCoachUnavailableTitle;

  /// No description provided for @linkCoachUnavailableText.
  ///
  /// In en, this message translates to:
  /// **'Try again later or contact your coach.'**
  String get linkCoachUnavailableText;

  /// No description provided for @linkVerifyInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'This confirmation link is invalid or has expired'**
  String get linkVerifyInvalidTitle;

  /// No description provided for @linkVerifyAlreadyConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your email is already confirmed.'**
  String get linkVerifyAlreadyConfirmed;

  /// No description provided for @linkVerifyResendText.
  ///
  /// In en, this message translates to:
  /// **'We can send you a new link.'**
  String get linkVerifyResendText;

  /// No description provided for @linkResetInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'This reset link is invalid or has expired'**
  String get linkResetInvalidTitle;

  /// No description provided for @linkResetAction.
  ///
  /// In en, this message translates to:
  /// **'Request a new link'**
  String get linkResetAction;

  /// No description provided for @error_UNKNOWN.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get error_UNKNOWN;

  /// No description provided for @error_NETWORK.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection.'**
  String get error_NETWORK;

  /// No description provided for @error_INTERNAL_ERROR.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again later.'**
  String get error_INTERNAL_ERROR;

  /// No description provided for @error_INVALID_CREDENTIALS.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get error_INVALID_CREDENTIALS;

  /// No description provided for @error_ACCOUNT_SUSPENDED.
  ///
  /// In en, this message translates to:
  /// **'Your account is suspended.'**
  String get error_ACCOUNT_SUSPENDED;

  /// No description provided for @error_RATE_LIMITED.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {minutes} min.'**
  String error_RATE_LIMITED(int minutes);

  /// No description provided for @error_EMAIL_TAKEN.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get error_EMAIL_TAKEN;

  /// No description provided for @error_ALREADY_HAS_COACH.
  ///
  /// In en, this message translates to:
  /// **'This account already has a coach.'**
  String get error_ALREADY_HAS_COACH;

  /// No description provided for @error_REQUIRED.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get error_REQUIRED;

  /// No description provided for @error_TOO_LONG.
  ///
  /// In en, this message translates to:
  /// **'Too long'**
  String get error_TOO_LONG;

  /// No description provided for @error_INVALID_EMAIL.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get error_INVALID_EMAIL;

  /// No description provided for @error_PASSWORD_POLICY.
  ///
  /// In en, this message translates to:
  /// **'Use 10–64 characters'**
  String get error_PASSWORD_POLICY;

  /// No description provided for @error_PASSWORDS_DONT_MATCH.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get error_PASSWORDS_DONT_MATCH;

  /// No description provided for @error_INVALID_LOCALE.
  ///
  /// In en, this message translates to:
  /// **'This language is not supported.'**
  String get error_INVALID_LOCALE;

  /// No description provided for @error_INVALID_TIMEZONE.
  ///
  /// In en, this message translates to:
  /// **'This time zone is not supported.'**
  String get error_INVALID_TIMEZONE;

  /// No description provided for @error_INVITE_EXPIRED.
  ///
  /// In en, this message translates to:
  /// **'This invite has expired.'**
  String get error_INVITE_EXPIRED;

  /// No description provided for @error_INVITE_USED.
  ///
  /// In en, this message translates to:
  /// **'This invite was already used.'**
  String get error_INVITE_USED;

  /// No description provided for @error_INVITE_REVOKED.
  ///
  /// In en, this message translates to:
  /// **'This invite is no longer valid.'**
  String get error_INVITE_REVOKED;

  /// No description provided for @error_INVITE_NOT_FOUND.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this invite.'**
  String get error_INVITE_NOT_FOUND;

  /// No description provided for @error_COACH_UNAVAILABLE.
  ///
  /// In en, this message translates to:
  /// **'Your coach isn\'t available right now.'**
  String get error_COACH_UNAVAILABLE;

  /// No description provided for @error_INVALID_TOKEN.
  ///
  /// In en, this message translates to:
  /// **'This link is invalid or has expired.'**
  String get error_INVALID_TOKEN;
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
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
