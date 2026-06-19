import '../catalog_enums.dart';

final class ProductMediaMetadata {
  const ProductMediaMetadata({
    required this.id,
    required this.type,
    required this.storagePath,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.sortOrder,
    required this.isPrimary,
    required this.uploadedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final ProductMediaType type;
  final String storagePath;
  final String mimeType;
  final int fileSizeBytes;
  final int sortOrder;
  final bool isPrimary;
  final String uploadedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
}
