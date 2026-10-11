// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Ana Fit Lab';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get passwordHint => '10–64 characters';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get goToLogin => 'Go to login';

  @override
  String get goHome => 'Go home';

  @override
  String get retry => 'Retry';

  @override
  String get cantReachServer => 'Can\'t reach the server';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginButton => 'Sign in';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get newCoachPrompt => 'New coach?';

  @override
  String get createAccountLink => 'Create an account';

  @override
  String get sessionEndedNotice => 'Your session ended. Please sign in again.';

  @override
  String get accountSuspendedNotice => 'Your account is suspended.';

  @override
  String get registerTitle => 'Create your coach account';

  @override
  String get registerButton => 'Create account';

  @override
  String get haveAccountPrompt => 'Already have an account?';

  @override
  String get signInLink => 'Sign in';

  @override
  String joinTitle(String coachName) {
    return 'You\'re joining $coachName\'s coaching';
  }

  @override
  String get joinButton => 'Create account and join';

  @override
  String joinSignedIn(String email) {
    return 'You\'re signed in as $email';
  }

  @override
  String get joinSignOut => 'Sign out to create a new account';

  @override
  String get verifyingEmail => 'Confirming your email…';

  @override
  String get emailConfirmedTitle => 'Email confirmed';

  @override
  String get emailConfirmedText => 'Your account is ready.';

  @override
  String get forgotTitle => 'Reset your password';

  @override
  String get forgotText => 'Enter your email and we\'ll send you a link.';

  @override
  String get forgotButton => 'Send reset link';

  @override
  String get forgotSent =>
      'If an account exists for that email, we\'ve sent a link to reset the password.';

  @override
  String get resetTitle => 'Set a new password';

  @override
  String get resetButton => 'Set new password';

  @override
  String homeGreeting(String firstName) {
    return 'Hello, $firstName';
  }

  @override
  String get roleCoach => 'Coach';

  @override
  String get roleClient => 'Client';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get signOut => 'Sign out';

  @override
  String pendingBanner(String email) {
    return 'Confirm your email – we sent a link to $email';
  }

  @override
  String get resend => 'Resend';

  @override
  String get resent => 'Sent';

  @override
  String get linkInviteExpiredTitle => 'This invite has expired';

  @override
  String get linkInviteExpiredText => 'Ask your coach for a new one.';

  @override
  String get linkInviteUsedTitle => 'This invite was already used';

  @override
  String get linkInviteUsedText => 'If it was you, sign in.';

  @override
  String get linkInviteRevokedTitle => 'This invite is no longer valid';

  @override
  String get linkInviteRevokedText => 'Ask your coach for a new one.';

  @override
  String get linkInviteNotFoundTitle => 'We couldn\'t find this invite';

  @override
  String get linkInviteNotFoundText => 'Check the link and try again.';

  @override
  String get linkCoachUnavailableTitle =>
      'Your coach isn\'t available right now';

  @override
  String get linkCoachUnavailableText =>
      'Try again later or contact your coach.';

  @override
  String get linkVerifyInvalidTitle =>
      'This confirmation link is invalid or has expired';

  @override
  String get linkVerifyAlreadyConfirmed => 'Your email is already confirmed.';

  @override
  String get linkVerifyResendText => 'We can send you a new link.';

  @override
  String get linkResetInvalidTitle =>
      'This reset link is invalid or has expired';

  @override
  String get linkResetAction => 'Request a new link';

  @override
  String get error_UNKNOWN => 'Something went wrong. Please try again.';

  @override
  String get error_NETWORK => 'Can\'t reach the server. Check your connection.';

  @override
  String get error_INTERNAL_ERROR =>
      'Something went wrong on our side. Please try again later.';

  @override
  String get error_INVALID_CREDENTIALS => 'Email or password is incorrect.';

  @override
  String get error_ACCOUNT_SUSPENDED => 'Your account is suspended.';

  @override
  String error_RATE_LIMITED(int minutes) {
    return 'Too many attempts. Try again in $minutes min.';
  }

  @override
  String get error_EMAIL_TAKEN => 'An account with this email already exists.';

  @override
  String get error_ALREADY_HAS_COACH => 'This account already has a coach.';

  @override
  String get error_REQUIRED => 'Required';

  @override
  String get error_TOO_LONG => 'Too long';

  @override
  String get error_INVALID_EMAIL => 'Enter a valid email';

  @override
  String get error_PASSWORD_POLICY => 'Use 10–64 characters';

  @override
  String get error_PASSWORDS_DONT_MATCH => 'Passwords don\'t match';

  @override
  String get error_INVALID_LOCALE => 'This language is not supported.';

  @override
  String get error_INVALID_TIMEZONE => 'This time zone is not supported.';

  @override
  String get error_INVITE_EXPIRED => 'This invite has expired.';

  @override
  String get error_INVITE_USED => 'This invite was already used.';

  @override
  String get error_INVITE_REVOKED => 'This invite is no longer valid.';

  @override
  String get error_INVITE_NOT_FOUND => 'We couldn\'t find this invite.';

  @override
  String get error_COACH_UNAVAILABLE =>
      'Your coach isn\'t available right now.';

  @override
  String get error_INVALID_TOKEN => 'This link is invalid or has expired.';
}
