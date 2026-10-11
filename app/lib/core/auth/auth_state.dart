import '../api/generated/export.dart';

enum SignedOutReason { sessionEnded, suspended }

/// What the router listens to. Value equality, so re-applying the same user
/// (e.g. after a token refresh) does not notify listeners.
sealed class AuthState {
  const AuthState();
}

/// Session not resolved yet. [unreachable]: the start-up refresh failed
/// because the server could not be reached (the stored token is kept).
final class AuthUnknown extends AuthState {
  const AuthUnknown({this.unreachable = false});

  final bool unreachable;

  @override
  bool operator ==(Object other) =>
      other is AuthUnknown && other.unreachable == unreachable;

  @override
  int get hashCode => Object.hash(AuthUnknown, unreachable);

  @override
  String toString() => 'AuthUnknown(unreachable: $unreachable)';
}

final class SignedOut extends AuthState {
  const SignedOut({this.reason});

  final SignedOutReason? reason;

  @override
  bool operator ==(Object other) =>
      other is SignedOut && other.reason == reason;

  @override
  int get hashCode => Object.hash(SignedOut, reason);

  @override
  String toString() => 'SignedOut(reason: $reason)';
}

final class SignedIn extends AuthState {
  const SignedIn(this.user);

  final UserResponse user;

  @override
  bool operator ==(Object other) => other is SignedIn && other.user == user;

  @override
  int get hashCode => Object.hash(SignedIn, user);

  @override
  String toString() => 'SignedIn(${user.email})';
}
