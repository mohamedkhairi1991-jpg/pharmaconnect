import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_l10n/pharmaconnect_l10n.dart';

void main() {
  test('English and Arabic locales are supported', () {
    expect(
      AppLocalizations.supportedLocales,
      containsAll(const <Locale>[Locale('en'), Locale('ar')]),
    );
  });
}
