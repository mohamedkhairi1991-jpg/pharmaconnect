import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';

void main() {
  test('Arabic content falls back to required English content', () {
    const LocalizedContent<String> content = LocalizedContent<String>(
      english: 'English',
    );

    expect(content.resolve(ContentLocale.arabic), 'English');
    expect(content.hasRequiredEnglish, isTrue);
  });

  test('Arabic content is preferred when available', () {
    const LocalizedContent<String> content = LocalizedContent<String>(
      english: 'English',
      arabic: 'Arabic',
    );

    expect(content.resolve(ContentLocale.arabic), 'Arabic');
    expect(content.resolve(ContentLocale.english), 'English');
  });

  test('missing English is observable and never falls back to Arabic', () {
    const LocalizedContent<String> content = LocalizedContent<String>(
      english: null,
      arabic: 'Arabic',
    );

    expect(content.hasRequiredEnglish, isFalse);
    expect(content.resolve(ContentLocale.english), isNull);
  });
}
