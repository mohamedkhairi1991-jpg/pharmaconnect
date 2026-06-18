import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('mapAuthException', () {
    test('maps invalid credentials', () {
      final AuthFailure failure = mapAuthException(
        const AuthException('Invalid login credentials'),
      );

      expect(failure.kind, AuthFailureKind.invalidCredentials);
    });

    test('maps unconfirmed email', () {
      final AuthFailure failure = mapAuthException(
        const AuthException('Email not confirmed'),
      );

      expect(failure.kind, AuthFailureKind.emailNotConfirmed);
    });

    test('does not expose unknown server messages', () {
      final AuthFailure failure = mapAuthException(
        const AuthException('Internal implementation detail'),
      );

      expect(failure.kind, AuthFailureKind.unexpected);
      expect(failure.toString(), isNot(contains('implementation detail')));
    });
  });
}
