import '../localization/localized_content.dart';
import 'taxonomy_translation.dart';

final class ActiveIngredient {
  const ActiveIngredient({
    required this.id,
    required this.code,
    required this.isActive,
    required this.translations,
  });

  final String id;
  final String code;
  final bool isActive;
  final LocalizedContent<TaxonomyTranslation> translations;
}
