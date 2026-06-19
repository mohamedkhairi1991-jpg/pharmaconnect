import '../localization/localized_content.dart';
import 'drug_class.dart';
import 'generic_composition_entry.dart';
import 'taxonomy_translation.dart';

final class GenericDrug {
  GenericDrug({
    required this.id,
    required this.code,
    required this.drugClass,
    required this.isActive,
    required this.translations,
    required Iterable<GenericCompositionEntry> composition,
  }) : composition = List<GenericCompositionEntry>.unmodifiable(composition);

  final String id;
  final String code;
  final DrugClass drugClass;
  final bool isActive;
  final LocalizedContent<TaxonomyTranslation> translations;
  final List<GenericCompositionEntry> composition;
}
