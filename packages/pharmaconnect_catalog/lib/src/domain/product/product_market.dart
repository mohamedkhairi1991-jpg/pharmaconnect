import '../catalog_enums.dart';
import '../localization/localized_content.dart';
import 'product_market_translation.dart';

final class ProductMarket {
  const ProductMarket({
    required this.id,
    required this.countryId,
    required this.strength,
    required this.dosageForm,
    required this.route,
    required this.packSize,
    required this.marketStatus,
    required this.registrationStatus,
    required this.translations,
    required this.createdAt,
    required this.updatedAt,
    this.registrationNumber,
    this.registrationAuthority,
    this.registrationExpiresOn,
  });

  final String id;
  final String countryId;
  final String strength;
  final String dosageForm;
  final String route;
  final String packSize;
  final IraqMarketStatus marketStatus;
  final ProductRegistrationStatus registrationStatus;
  final String? registrationNumber;
  final String? registrationAuthority;
  final DateTime? registrationExpiresOn;
  final LocalizedContent<ProductMarketTranslation> translations;
  final DateTime createdAt;
  final DateTime updatedAt;
}
