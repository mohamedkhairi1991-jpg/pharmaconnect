import 'package:pharmaconnect_core/pharmaconnect_core.dart';
import 'package:test/test.dart';

void main() {
  test('development is the default environment', () {
    expect(AppEnvironment.fromDartDefines(), AppEnvironment.development);
  });
}
