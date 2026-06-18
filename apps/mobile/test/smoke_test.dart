import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_mobile/app/mobile_app.dart';

void main() {
  testWidgets('mobile application shell starts', (WidgetTester tester) async {
    await tester.pumpWidget(const MobileApp());
    await tester.pump();

    expect(find.byType(MobileApp), findsOneWidget);
  });
}
