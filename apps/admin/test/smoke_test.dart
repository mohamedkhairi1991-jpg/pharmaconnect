import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_admin/app/admin_app.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_identity/pharmaconnect_identity.dart';

void main() {
  testWidgets('admin application shell starts', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWithValue(
            const AsyncData(AuthSessionState.signedOut()),
          ),
          sessionPrincipalProvider.overrideWithValue(const AsyncData(null)),
        ],
        child: const AdminApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(AdminApp), findsOneWidget);
  });
}
