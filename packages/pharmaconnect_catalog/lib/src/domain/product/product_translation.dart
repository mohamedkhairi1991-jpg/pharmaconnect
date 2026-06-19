import '../catalog_enums.dart';

final class ProductTranslation {
  const ProductTranslation({
    required this.id,
    required this.locale,
    required this.brandName,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final ContentLocale locale;
  final String brandName;
  final DateTime createdAt;
  final DateTime updatedAt;
}
