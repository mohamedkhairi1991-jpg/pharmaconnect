import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late _MockGoTrueClient auth;
  late SupabaseAuthRepository repository;

  setUp(() {
    auth = _MockGoTrueClient();
    repository = SupabaseAuthRepository(auth);
  });

  test('sign in normalizes the email address', () async {
    when(
      () => auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AuthResponse());

    await repository.signIn(
      email: '  Person@Example.COM ',
      password: 'password123',
    );

    verify(
      () => auth.signInWithPassword(
        email: 'person@example.com',
        password: 'password123',
      ),
    ).called(1);
  });

  test('sign up reports that email confirmation is required', () async {
    when(
      () => auth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        emailRedirectTo: any(named: 'emailRedirectTo'),
      ),
    ).thenAnswer((_) async => AuthResponse());

    final SignUpResult result = await repository.signUp(
      email: 'person@example.com',
      password: 'password123',
      emailRedirectTo: 'com.pharmaconnect.mobile://auth/callback',
    );

    expect(result.confirmationRequired, isTrue);
  });

  test('auth stream maps signed out and password recovery states', () async {
    const User user = User(
      id: 'user-id',
      appMetadata: <String, dynamic>{},
      userMetadata: <String, dynamic>{},
      aud: 'authenticated',
      email: 'person@example.com',
      createdAt: '2026-01-01T00:00:00Z',
    );
    final Session session = Session(
      accessToken: 'access-token',
      tokenType: 'bearer',
      user: user,
    );
    when(() => auth.onAuthStateChange).thenAnswer(
      (_) => Stream<AuthState>.fromIterable(<AuthState>[
        const AuthState(AuthChangeEvent.signedOut, null),
        AuthState(AuthChangeEvent.passwordRecovery, session),
      ]),
    );

    final List<AuthSessionState> states = await repository
        .observeSession()
        .toList();

    expect(states.first.phase, AuthSessionPhase.signedOut);
    expect(states.last.phase, AuthSessionPhase.passwordRecovery);
    expect(states.last.userId, 'user-id');
  });
}
