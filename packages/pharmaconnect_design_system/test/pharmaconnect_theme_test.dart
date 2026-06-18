import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';

void main() {
  test('light theme uses Material 3', () {
    expect(PharmaConnectTheme.light().useMaterial3, isTrue);
  });
}
