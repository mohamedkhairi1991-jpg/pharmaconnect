final class ProductLifecycleMetadata {
  const ProductLifecycleMetadata({
    this.submittedBy,
    this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewReason,
    this.publishedBy,
    this.publishedAt,
    this.hiddenBy,
    this.hiddenAt,
    this.hiddenReason,
    this.archivedBy,
    this.archivedAt,
    this.archiveReason,
  });

  final String? submittedBy;
  final DateTime? submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewReason;
  final String? publishedBy;
  final DateTime? publishedAt;
  final String? hiddenBy;
  final DateTime? hiddenAt;
  final String? hiddenReason;
  final String? archivedBy;
  final DateTime? archivedAt;
  final String? archiveReason;
}
