import '../../domain/catalog_enums.dart';
import '../../domain/localization/localized_content.dart';
import '../../domain/taxonomy/active_ingredient.dart';
import '../../domain/taxonomy/drug_class.dart';
import '../../domain/taxonomy/generic_composition_entry.dart';
import '../../domain/taxonomy/generic_drug.dart';
import '../../domain/taxonomy/product_specialty.dart';
import '../../domain/taxonomy/taxonomy_translation.dart';
import '../parsing/json_reader.dart';

final class DrugClassTranslationDto {
  const DrugClassTranslationDto({
    required this.locale,
    required this.name,
    this.description,
  });

  factory DrugClassTranslationDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(
      json,
      context: 'drug_class_translation',
    );
    return DrugClassTranslationDto(
      locale: ContentLocale.fromDatabaseValue(reader.string('locale')),
      name: reader.string('name'),
      description: reader.nullableString('description'),
    );
  }

  final ContentLocale locale;
  final String name;
  final String? description;

  TaxonomyTranslation toDomain() =>
      TaxonomyTranslation(locale: locale, name: name, description: description);
}

final class DrugClassDto {
  DrugClassDto({
    required this.id,
    required this.code,
    required this.isActive,
    required Iterable<DrugClassTranslationDto> translations,
    this.parentDrugClassId,
  }) : translations = List<DrugClassTranslationDto>.unmodifiable(translations);

  factory DrugClassDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json, context: 'drug_class');
    return DrugClassDto(
      id: reader.string('id'),
      code: reader.string('code'),
      parentDrugClassId: reader.nullableString('parent_drug_class_id'),
      isActive: reader.boolean('is_active'),
      translations: reader
          .objects('drug_class_translations')
          .map(DrugClassTranslationDto.fromJson),
    );
  }

  final String id;
  final String code;
  final String? parentDrugClassId;
  final bool isActive;
  final List<DrugClassTranslationDto> translations;

  DrugClass toDomain() => DrugClass(
    id: id,
    code: code,
    parentDrugClassId: parentDrugClassId,
    isActive: isActive,
    translations: _localizedTaxonomy(
      translations.map((DrugClassTranslationDto value) => value.toDomain()),
    ),
  );
}

final class ActiveIngredientTranslationDto {
  const ActiveIngredientTranslationDto({
    required this.locale,
    required this.name,
    this.description,
  });

  factory ActiveIngredientTranslationDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(
      json,
      context: 'active_ingredient_translation',
    );
    return ActiveIngredientTranslationDto(
      locale: ContentLocale.fromDatabaseValue(reader.string('locale')),
      name: reader.string('name'),
      description: reader.nullableString('description'),
    );
  }

  final ContentLocale locale;
  final String name;
  final String? description;

  TaxonomyTranslation toDomain() =>
      TaxonomyTranslation(locale: locale, name: name, description: description);
}

final class ActiveIngredientDto {
  ActiveIngredientDto({
    required this.id,
    required this.code,
    required this.isActive,
    required Iterable<ActiveIngredientTranslationDto> translations,
  }) : translations = List<ActiveIngredientTranslationDto>.unmodifiable(
         translations,
       );

  factory ActiveIngredientDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json, context: 'active_ingredient');
    return ActiveIngredientDto(
      id: reader.string('id'),
      code: reader.string('code'),
      isActive: reader.boolean('is_active'),
      translations: reader
          .objects('active_ingredient_translations')
          .map(ActiveIngredientTranslationDto.fromJson),
    );
  }

  final String id;
  final String code;
  final bool isActive;
  final List<ActiveIngredientTranslationDto> translations;

  ActiveIngredient toDomain() => ActiveIngredient(
    id: id,
    code: code,
    isActive: isActive,
    translations: _localizedTaxonomy(
      translations.map(
        (ActiveIngredientTranslationDto value) => value.toDomain(),
      ),
    ),
  );
}

final class GenericDrugTranslationDto {
  const GenericDrugTranslationDto({
    required this.locale,
    required this.name,
    this.description,
  });

  factory GenericDrugTranslationDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(
      json,
      context: 'generic_drug_translation',
    );
    return GenericDrugTranslationDto(
      locale: ContentLocale.fromDatabaseValue(reader.string('locale')),
      name: reader.string('name'),
      description: reader.nullableString('description'),
    );
  }

  final ContentLocale locale;
  final String name;
  final String? description;

  TaxonomyTranslation toDomain() =>
      TaxonomyTranslation(locale: locale, name: name, description: description);
}

final class GenericCompositionEntryDto {
  const GenericCompositionEntryDto({
    required this.sortOrder,
    required this.ingredient,
  });

  factory GenericCompositionEntryDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(
      json,
      context: 'generic_composition_entry',
    );
    return GenericCompositionEntryDto(
      sortOrder: reader.integer('sort_order'),
      ingredient: ActiveIngredientDto.fromJson(
        reader.object('active_ingredients'),
      ),
    );
  }

  final int sortOrder;
  final ActiveIngredientDto ingredient;

  GenericCompositionEntry toDomain() => GenericCompositionEntry(
    ingredient: ingredient.toDomain(),
    sortOrder: sortOrder,
  );
}

final class GenericDrugDto {
  GenericDrugDto({
    required this.id,
    required this.code,
    required this.isActive,
    required this.drugClass,
    required Iterable<GenericDrugTranslationDto> translations,
    required Iterable<GenericCompositionEntryDto> composition,
  }) : translations = List<GenericDrugTranslationDto>.unmodifiable(
         translations,
       ),
       composition = List<GenericCompositionEntryDto>.unmodifiable(composition);

  factory GenericDrugDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json, context: 'generic_drug');
    return GenericDrugDto(
      id: reader.string('id'),
      code: reader.string('code'),
      isActive: reader.boolean('is_active'),
      drugClass: DrugClassDto.fromJson(reader.object('drug_classes')),
      translations: reader
          .objects('generic_drug_translations')
          .map(GenericDrugTranslationDto.fromJson),
      composition: reader
          .objects('generic_drug_ingredients')
          .map(GenericCompositionEntryDto.fromJson),
    );
  }

  final String id;
  final String code;
  final bool isActive;
  final DrugClassDto drugClass;
  final List<GenericDrugTranslationDto> translations;
  final List<GenericCompositionEntryDto> composition;

  GenericDrug toDomain() => GenericDrug(
    id: id,
    code: code,
    drugClass: drugClass.toDomain(),
    isActive: isActive,
    translations: _localizedTaxonomy(
      translations.map((GenericDrugTranslationDto value) => value.toDomain()),
    ),
    composition:
        composition
            .map((GenericCompositionEntryDto value) => value.toDomain())
            .toList()
          ..sort(
            (GenericCompositionEntry first, GenericCompositionEntry second) =>
                first.sortOrder.compareTo(second.sortOrder),
          ),
  );
}

final class ProductSpecialtyDto {
  ProductSpecialtyDto({
    required this.id,
    required this.code,
    required this.isActive,
    required Iterable<DrugClassTranslationDto> translations,
    this.professionType,
  }) : translations = List<DrugClassTranslationDto>.unmodifiable(translations);

  factory ProductSpecialtyDto.fromJson(Map<String, Object?> json) {
    final JsonReader relation = JsonReader(
      json,
      context: 'product_specialty_relation',
    );
    final JsonReader reader = JsonReader(
      relation.nullableObject('specialties') ?? json,
      context: 'product_specialty',
    );
    final String? profession = reader.nullableString('profession_type');
    return ProductSpecialtyDto(
      id: reader.string('id'),
      code: reader.string('code'),
      isActive: reader.boolean('is_active'),
      professionType: profession == null
          ? null
          : ProfessionType.fromDatabaseValue(profession),
      translations: reader
          .objects('specialty_translations')
          .map(DrugClassTranslationDto.fromJson),
    );
  }

  final String id;
  final String code;
  final bool isActive;
  final ProfessionType? professionType;
  final List<DrugClassTranslationDto> translations;

  ProductSpecialty toDomain() => ProductSpecialty(
    id: id,
    code: code,
    professionType: professionType,
    isActive: isActive,
    translations: _localizedTaxonomy(
      translations.map((DrugClassTranslationDto value) => value.toDomain()),
    ),
  );
}

LocalizedContent<TaxonomyTranslation> _localizedTaxonomy(
  Iterable<TaxonomyTranslation> values,
) {
  TaxonomyTranslation? english;
  TaxonomyTranslation? arabic;
  for (final TaxonomyTranslation value in values) {
    if (value.locale == ContentLocale.english) {
      english = value;
    } else {
      arabic = value;
    }
  }
  return LocalizedContent<TaxonomyTranslation>(
    english: english,
    arabic: arabic,
  );
}
