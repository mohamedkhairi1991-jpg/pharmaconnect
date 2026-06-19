import '../catalog_enums.dart';

final class ProductMarketTranslation {
  const ProductMarketTranslation({
    required this.id,
    required this.locale,
    required this.storageConditions,
    required this.approvedIndications,
    required this.usualAdultDose,
    required this.contraindications,
    required this.commonAdverseEffects,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final ContentLocale locale;
  final String storageConditions;
  final String approvedIndications;
  final String usualAdultDose;
  final String contraindications;
  final String commonAdverseEffects;
  final DateTime createdAt;
  final DateTime updatedAt;
}
