import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_admin/features/authentication/presentation/auth_support.dart';
import 'package:pharmaconnect_admin/features/authentication/presentation/session_pages.dart';
import 'package:pharmaconnect_admin/features/authentication/presentation/sign_in_page.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';

void main() {
  testWidgets('admin sign in validates required fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AdminSignInPage(),
      ),
    );

    await tester.tap(find.byKey(const Key('adminSignInSubmit')));
    await tester.pump();

    expect(find.text('This field is required.'), findsNWidgets(2));
    expect(find.text('Pharamty'), findsOneWidget);
  });

  testWidgets('admin auth loading and access states use branded presentation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp(const AdminSessionLoadingPage()));

    expect(find.text('Pharamty'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Restoring your session…'), findsOneWidget);

    await tester.pumpWidget(_testApp(const AdminUnauthorizedPage()));
    await tester.pump();

    expect(find.text('Use the correct application'), findsOneWidget);
    expect(find.byType(AdminAuthStatusPanel), findsOneWidget);

    await tester.pumpWidget(_testApp(const AdminAccountUnavailablePage()));
    await tester.pump();

    expect(find.text('Account unavailable'), findsOneWidget);
    expect(
      find.text('This account cannot currently access Pharamty.'),
      findsOneWidget,
    );
  });

  testWidgets('admin sign in uses the wide responsive layout safely', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(const AdminSignInPage()));
    await tester.pump();

    expect(find.text('Pharamty'), findsOneWidget);
    expect(find.text('Administration portal'), findsOneWidget);
    expect(find.byKey(const Key('adminSignInSubmit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget home) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: PharmaConnectTheme.dark(),
      home: home,
    ),
  );
}
