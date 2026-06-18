import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_admin/app/admin_app.dart';

void main() {
  testWidgets('admin application shell starts', (WidgetTester tester) async {
    await tester.pumpWidget(const AdminApp());
    await tester.pump();

    expect(find.byType(AdminApp), findsOneWidget);
  });
}
