import '../catalog_enums.dart';

final class ProductBrochureMetadata {
  const ProductBrochureMetadata({
    required this.id,
    required this.productMarketId,
    required this.locale,
    required this.title,
    required this.storagePath,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.version,
    required this.isCurrent,
    required this.uploadedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String productMarketId;
  final ContentLocale locale;
  final String title;
  final String storagePath;
  final String mimeType;
  final int fileSizeBytes;
  final int version;
  final bool isCurrent;
  final String uploadedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
}
