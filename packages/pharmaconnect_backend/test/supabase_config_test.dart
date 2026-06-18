import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';

void main() {
  test('empty Supabase placeholders are not configured', () {
    const SupabaseConfig config = SupabaseConfig(url: '', anonKey: '');

    expect(config.isConfigured, isFalse);
  });
}
