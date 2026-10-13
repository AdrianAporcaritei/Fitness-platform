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

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get navClients;

  /// No description provided for @navWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get navWorkouts;

  /// No description provided for @navMealPlans.
  ///
  /// In en, this message translates to:
  /// **'Meal plans'**
  String get navMealPlans;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get navComingSoon;

  /// No description provided for @openMenu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get openMenu;

  /// No description provided for @clientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clientsTitle;

  /// No description provided for @addClientButton.
  ///
  /// In en, this message translates to:
  /// **'+ Add client'**
  String get addClientButton;

  /// No description provided for @addClientNeedsVerifiedEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email to add clients.'**
  String get addClientNeedsVerifiedEmail;

  /// No description provided for @clientsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email'**
  String get clientsSearchHint;

  /// No description provided for @clientsStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get clientsStatusAll;

  /// No description provided for @clientsStatusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get clientsStatusFilter;

  /// No description provided for @clientStatusInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get clientStatusInvited;

  /// No description provided for @clientStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get clientStatusActive;

  /// No description provided for @clientStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get clientStatusPaused;

  /// No description provided for @clientStatusEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get clientStatusEnded;

  /// No description provided for @clientsColumnName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get clientsColumnName;

  /// No description provided for @clientsColumnEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get clientsColumnEmail;

  /// No description provided for @clientsColumnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get clientsColumnStatus;

  /// No description provided for @clientsColumnInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited on'**
  String get clientsColumnInvited;

  /// No description provided for @clientsInvitationExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String clientsInvitationExpires(String date);

  /// No description provided for @clientsInvitationExpired.
  ///
  /// In en, this message translates to:
  /// **'Invitation expired'**
  String get clientsInvitationExpired;

  /// No description provided for @clientsNoName.
  ///
  /// In en, this message translates to:
  /// **'(no name)'**
  String get clientsNoName;

  /// No description provided for @clientsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No clients yet'**
  String get clientsEmptyTitle;

  /// No description provided for @clientsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a client and send them the invitation link. Once they join, they show up here.'**
  String get clientsEmptyBody;

  /// No description provided for @clientsInviteFirst.
  ///
  /// In en, this message translates to:
  /// **'Invite your first client'**
  String get clientsInviteFirst;

  /// No description provided for @clientsNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No clients match these filters'**
  String get clientsNoMatchTitle;

  /// No description provided for @clientsClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clientsClearFilters;

  /// No description provided for @clientsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your clients.'**
  String get clientsLoadError;

  /// No description provided for @clientsRange.
  ///
  /// In en, this message translates to:
  /// **'{from}–{to} of {total}'**
  String clientsRange(int from, int to, int total);

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// No description provided for @invitationActions.
  ///
  /// In en, this message translates to:
  /// **'Invitation actions'**
  String get invitationActions;

  /// No description provided for @addClientTitle.
  ///
  /// In en, this message translates to:
  /// **'Add client'**
  String get addClientTitle;

  /// No description provided for @addClientIntro.
  ///
  /// In en, this message translates to:
  /// **'We\'ll create a personal invitation link for them. No email is sent – you share the link yourself.'**
  String get addClientIntro;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @createInvitation.
  ///
  /// In en, this message translates to:
  /// **'Create invitation'**
  String get createInvitation;

  /// No description provided for @invitationLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation link for {name}'**
  String invitationLinkTitle(String name);

  /// No description provided for @invitationLinkOnce.
  ///
  /// In en, this message translates to:
  /// **'Copy the link now and send it to your client. You won\'t be able to see it again after closing this window.'**
  String get invitationLinkOnce;

  /// No description provided for @invitationLinkExpires.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}.'**
  String invitationLinkExpires(String date);

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get linkCopied;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @regenerateLink.
  ///
  /// In en, this message translates to:
  /// **'Regenerate link'**
  String get regenerateLink;

  /// No description provided for @regenerateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Regenerate the link?'**
  String get regenerateConfirmTitle;

  /// No description provided for @regenerateConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The current link for {name} stops working and a new one, valid for 7 days, is created.'**
  String regenerateConfirmBody(String name);

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @cancelInvitation.
  ///
  /// In en, this message translates to:
  /// **'Cancel invitation'**
  String get cancelInvitation;

  /// No description provided for @cancelInvitationConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel the invitation?'**
  String get cancelInvitationConfirmTitle;

  /// No description provided for @cancelInvitationConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{name} won\'t be able to join with this link anymore.'**
  String cancelInvitationConfirmBody(String name);

  /// No description provided for @keepInvitation.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepInvitation;

  /// No description provided for @invitationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Invitation cancelled.'**
  String get invitationCancelled;

  /// No description provided for @error_INVITE_NOT_PENDING.
  ///
  /// In en, this message translates to:
  /// **'This invitation is no longer pending.'**
  String get error_INVITE_NOT_PENDING;

  /// No description provided for @error_INVITE_ALREADY_PENDING.
  ///
  /// In en, this message translates to:
  /// **'You already have a pending invitation for this email.'**
  String get error_INVITE_ALREADY_PENDING;

  /// No description provided for @error_ALREADY_YOUR_CLIENT.
  ///
  /// In en, this message translates to:
  /// **'This person is already your client.'**
  String get error_ALREADY_YOUR_CLIENT;

  /// No description provided for @error_EMAIL_NOT_VERIFIED.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email first.'**
  String get error_EMAIL_NOT_VERIFIED;

  /// No description provided for @clientActions.
  ///
  /// In en, this message translates to:
  /// **'Client actions'**
  String get clientActions;

  /// No description provided for @pauseClient.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseClient;

  /// No description provided for @resumeClient.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeClient;

  /// No description provided for @endRelationship.
  ///
  /// In en, this message translates to:
  /// **'End relationship'**
  String get endRelationship;

  /// No description provided for @endRelationshipConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'End the relationship with {name}?'**
  String endRelationshipConfirmTitle(String name);

  /// No description provided for @endRelationshipConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone. You\'ll lose access to this client\'s data, and they will be able to join another coach.'**
  String get endRelationshipConfirmBody;

  /// No description provided for @keepClient.
  ///
  /// In en, this message translates to:
  /// **'Keep client'**
  String get keepClient;

  /// No description provided for @relationshipPaused.
  ///
  /// In en, this message translates to:
  /// **'Relationship with {name} paused.'**
  String relationshipPaused(String name);

  /// No description provided for @relationshipResumed.
  ///
  /// In en, this message translates to:
  /// **'Relationship with {name} resumed.'**
  String relationshipResumed(String name);

  /// No description provided for @relationshipEnded.
  ///
  /// In en, this message translates to:
  /// **'Relationship with {name} ended.'**
  String relationshipEnded(String name);

  /// No description provided for @error_INVALID_RELATIONSHIP_TRANSITION.
  ///
  /// In en, this message translates to:
  /// **'This client\'s status changed in the meantime. The list is up to date now.'**
  String get error_INVALID_RELATIONSHIP_TRANSITION;

  /// No description provided for @error_CLIENT_NOT_FOUND.
  ///
  /// In en, this message translates to:
  /// **'This client is no longer linked to you.'**
  String get error_CLIENT_NOT_FOUND;
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
