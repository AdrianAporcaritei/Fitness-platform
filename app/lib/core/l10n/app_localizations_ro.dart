// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appName => 'Ana Fit Lab';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Parolă';

  @override
  String get newPasswordLabel => 'Parolă nouă';

  @override
  String get confirmPasswordLabel => 'Confirmă parola';

  @override
  String get firstNameLabel => 'Prenume';

  @override
  String get lastNameLabel => 'Nume';

  @override
  String get passwordHint => '10–64 de caractere';

  @override
  String get showPassword => 'Arată parola';

  @override
  String get hidePassword => 'Ascunde parola';

  @override
  String get goToLogin => 'Mergi la autentificare';

  @override
  String get goHome => 'Mergi la pagina principală';

  @override
  String get retry => 'Reîncearcă';

  @override
  String get cantReachServer => 'Nu ne putem conecta la server';

  @override
  String get loginTitle => 'Conectează-te';

  @override
  String get loginButton => 'Conectează-te';

  @override
  String get forgotPasswordLink => 'Ai uitat parola?';

  @override
  String get newCoachPrompt => 'Antrenor nou?';

  @override
  String get createAccountLink => 'Creează un cont';

  @override
  String get sessionEndedNotice =>
      'Sesiunea ta s-a încheiat. Conectează-te din nou.';

  @override
  String get accountSuspendedNotice => 'Contul tău este suspendat.';

  @override
  String get registerTitle => 'Creează-ți contul de antrenor';

  @override
  String get registerButton => 'Creează cont';

  @override
  String get haveAccountPrompt => 'Ai deja un cont?';

  @override
  String get signInLink => 'Conectează-te';

  @override
  String joinTitle(String coachName) {
    return 'Te alături antrenamentelor lui $coachName';
  }

  @override
  String get joinButton => 'Creează cont și alătură-te';

  @override
  String joinSignedIn(String email) {
    return 'Ești conectat ca $email';
  }

  @override
  String get joinSignOut => 'Deconectează-te pentru a crea un cont nou';

  @override
  String get verifyingEmail => 'Se confirmă emailul…';

  @override
  String get emailConfirmedTitle => 'Email confirmat';

  @override
  String get emailConfirmedText => 'Contul tău este gata.';

  @override
  String get forgotTitle => 'Resetează-ți parola';

  @override
  String get forgotText => 'Introdu adresa de email și îți trimitem un link.';

  @override
  String get forgotButton => 'Trimite linkul de resetare';

  @override
  String get forgotSent =>
      'Dacă există un cont pentru acest email, am trimis un link pentru resetarea parolei.';

  @override
  String get resetTitle => 'Setează o parolă nouă';

  @override
  String get resetButton => 'Setează parola nouă';

  @override
  String homeGreeting(String firstName) {
    return 'Salut, $firstName';
  }

  @override
  String get roleCoach => 'Antrenor';

  @override
  String get roleClient => 'Client';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get signOut => 'Deconectează-te';

  @override
  String pendingBanner(String email) {
    return 'Confirmă-ți emailul – am trimis un link la $email';
  }

  @override
  String get resend => 'Retrimite';

  @override
  String get resent => 'Trimis';

  @override
  String get linkInviteExpiredTitle => 'Această invitație a expirat';

  @override
  String get linkInviteExpiredText => 'Cere antrenorului tău una nouă.';

  @override
  String get linkInviteUsedTitle => 'Această invitație a fost deja folosită';

  @override
  String get linkInviteUsedText => 'Dacă ai folosit-o tu, conectează-te.';

  @override
  String get linkInviteRevokedTitle => 'Această invitație nu mai este valabilă';

  @override
  String get linkInviteRevokedText => 'Cere antrenorului tău una nouă.';

  @override
  String get linkInviteNotFoundTitle => 'Nu am găsit această invitație';

  @override
  String get linkInviteNotFoundText => 'Verifică linkul și încearcă din nou.';

  @override
  String get linkCoachUnavailableTitle =>
      'Antrenorul tău nu este disponibil momentan';

  @override
  String get linkCoachUnavailableText =>
      'Încearcă mai târziu sau contactează-ți antrenorul.';

  @override
  String get linkVerifyInvalidTitle =>
      'Acest link de confirmare este invalid sau a expirat';

  @override
  String get linkVerifyAlreadyConfirmed => 'Emailul tău este deja confirmat.';

  @override
  String get linkVerifyResendText => 'Îți putem trimite un link nou.';

  @override
  String get linkResetInvalidTitle =>
      'Acest link de resetare este invalid sau a expirat';

  @override
  String get linkResetAction => 'Solicită un link nou';

  @override
  String get error_UNKNOWN => 'Ceva nu a mers bine. Încearcă din nou.';

  @override
  String get error_NETWORK =>
      'Nu ne putem conecta la server. Verifică conexiunea.';

  @override
  String get error_INTERNAL_ERROR =>
      'Ceva nu a mers bine din partea noastră. Încearcă din nou mai târziu.';

  @override
  String get error_INVALID_CREDENTIALS => 'Emailul sau parola sunt incorecte.';

  @override
  String get error_ACCOUNT_SUSPENDED => 'Contul tău este suspendat.';

  @override
  String error_RATE_LIMITED(int minutes) {
    return 'Prea multe încercări. Încearcă din nou peste $minutes min.';
  }

  @override
  String get error_EMAIL_TAKEN => 'Există deja un cont cu acest email.';

  @override
  String get error_ALREADY_HAS_COACH => 'Acest cont are deja un antrenor.';

  @override
  String get error_REQUIRED => 'Câmp obligatoriu';

  @override
  String get error_TOO_LONG => 'Prea lung';

  @override
  String get error_INVALID_EMAIL => 'Introdu un email valid';

  @override
  String get error_PASSWORD_POLICY => 'Folosește 10–64 de caractere';

  @override
  String get error_PASSWORDS_DONT_MATCH => 'Parolele nu coincid';

  @override
  String get error_INVALID_LOCALE => 'Această limbă nu este acceptată.';

  @override
  String get error_INVALID_TIMEZONE => 'Acest fus orar nu este acceptat.';

  @override
  String get error_INVITE_EXPIRED => 'Această invitație a expirat.';

  @override
  String get error_INVITE_USED => 'Această invitație a fost deja folosită.';

  @override
  String get error_INVITE_REVOKED => 'Această invitație nu mai este valabilă.';

  @override
  String get error_INVITE_NOT_FOUND => 'Nu am găsit această invitație.';

  @override
  String get error_COACH_UNAVAILABLE =>
      'Antrenorul tău nu este disponibil momentan.';

  @override
  String get error_INVALID_TOKEN => 'Acest link este invalid sau a expirat.';
}
