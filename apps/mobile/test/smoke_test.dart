import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';
import 'package:pharmaconnect_mobile/app/mobile_app.dart';

void main() {
  testWidgets('mobile application shell starts', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWithValue(
            const AsyncData(AuthSessionState.signedOut()),
          ),
          sessionPrincipalProvider.overrideWithValue(const AsyncData(null)),
        ],
        child: const MobileApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(MobileApp), findsOneWidget);
  });
}
