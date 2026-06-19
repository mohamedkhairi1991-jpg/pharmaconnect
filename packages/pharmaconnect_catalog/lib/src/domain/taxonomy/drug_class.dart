import '../localization/localized_content.dart';
import 'taxonomy_translation.dart';

final class DrugClass {
  const DrugClass({
    required this.id,
    required this.code,
    required this.isActive,
    required this.translations,
    this.parentDrugClassId,
  });

  final String id;
  final String code;
  final String? parentDrugClassId;
  final bool isActive;
  final LocalizedContent<TaxonomyTranslation> translations;
}
