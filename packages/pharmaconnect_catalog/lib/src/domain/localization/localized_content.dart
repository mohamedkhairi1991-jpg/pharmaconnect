import '../catalog_enums.dart';

final class LocalizedContent<T> {
  const LocalizedContent({required this.english, this.arabic});

  final T? english;
  final T? arabic;

  bool get hasRequiredEnglish => english != null;

  T? resolve(ContentLocale preferredLocale) {
    return switch (preferredLocale) {
      ContentLocale.english => english,
      ContentLocale.arabic => arabic ?? english,
    };
  }
}
