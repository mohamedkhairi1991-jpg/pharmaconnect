import '../catalog_enums.dart';
import '../localization/localized_content.dart';
import 'taxonomy_translation.dart';

final class ProductSpecialty {
  const ProductSpecialty({
    required this.id,
    required this.code,
    required this.isActive,
    required this.translations,
    this.professionType,
  });

  final String id;
  final String code;
  final ProfessionType? professionType;
  final bool isActive;
  final LocalizedContent<TaxonomyTranslation> translations;
}
