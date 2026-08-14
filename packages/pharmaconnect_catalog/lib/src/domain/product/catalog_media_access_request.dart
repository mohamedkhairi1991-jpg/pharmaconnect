enum CatalogMediaAssetKind { productMedia, brochure }

final class CatalogMediaAccessRequest {
  const CatalogMediaAccessRequest({
    required this.kind,
    required this.storagePath,
  });

  final CatalogMediaAssetKind kind;
  final String storagePath;

  @override
  bool operator ==(Object other) =>
      other is CatalogMediaAccessRequest &&
      other.kind == kind &&
      other.storagePath == storagePath;

  @override
  int get hashCode => Object.hash(kind, storagePath);
}
