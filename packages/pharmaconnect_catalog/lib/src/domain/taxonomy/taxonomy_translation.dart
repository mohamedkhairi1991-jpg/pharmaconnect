import '../catalog_enums.dart';

final class TaxonomyTranslation {
  const TaxonomyTranslation({
    required this.locale,
    required this.name,
    this.description,
  });

  final ContentLocale locale;
  final String name;
  final String? description;
}
