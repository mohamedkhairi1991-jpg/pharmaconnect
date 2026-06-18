import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';
import 'package:pharmaconnect_mobile/features/authentication/presentation/sign_in_page.dart';

void main() {
  testWidgets('mobile sign in validates required fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MobileSignInPage(),
      ),
    );

    await tester.tap(find.byKey(const Key('mobileSignInSubmit')));
    await tester.pump();

    expect(find.text('This field is required.'), findsNWidgets(2));
  });
}
